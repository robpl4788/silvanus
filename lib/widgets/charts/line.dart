import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/src/rust/api/api.dart';
import 'package:silvanus/src/rust/api/types.dart';
import 'package:silvanus/types/series_request.dart';

class Line extends StatefulWidget {
  final SeriesGroupRequest seriesToShow;

  final ArcEngine engine;

  final Map<String, Series> seriesMap = {};

  Line({super.key, required this.seriesToShow, required this.engine});

 

  @override
  State<Line> createState() => _LineState();
  
}

class _LineState extends State<Line> {
  
  double? minTimeToShow;
  double? maxTimeToShow;
  late final ZoomManager zoomManager;

  void setTimeToShow(({double? newMin, double? newMax}) newTime) {
    setState(() {
      minTimeToShow = newTime.newMin;
      maxTimeToShow = newTime.newMax;
    });
  }

  @override
  initState() {
    super.initState();
    zoomManager = ZoomManager(setTimeToShow);
    for (final seriesRequest in widget.seriesToShow.getAllRequests()) {
      _subscribeToSeries(seriesRequest);

    }

  }

  @override
  void didUpdateWidget(covariant Line oldWidget) {
    
    super.didUpdateWidget(oldWidget);
    widget.seriesMap.addEntries(oldWidget.seriesMap.entries);



    

    // If key currently in the set and shouldnt be remove it
    for (final key in widget.seriesMap.keys.toList()) {
      if (widget.seriesToShow.containsKey(key) == false) {
        widget.seriesMap[key]?.destroy();
        widget.seriesMap.remove(key);
      }
    }

    // If the key isn't in the set and should be add it
    for (final request in widget.seriesToShow.getAllRequests())   {
      if (widget.seriesMap.containsKey(request.getKey()) == false) {
        _subscribeToSeries(request);
      }
    }
  }

  void _subscribeToSeries(SeriesRequest seriesRequested) {

  
    List<FlSpot> newSpots = [];


    

    final sub = getTimestampedSeries(key: seriesRequested.getKey(), engine: widget.engine)
        .listen((pointsFromRust) {
        setState(() {
          newSpots =  pointsFromRust
              .map((p) => FlSpot(p.time, p.value))
              .toList();
          });

          zoomManager.addTimeMeasurement(pointsFromRust);

          widget.seriesMap[seriesRequested.getKey()]?.setSpots(newSpots);

        });
      Series newSeries = Series(sub, newSpots, seriesRequested);
      widget.seriesMap[seriesRequested.getKey()] = newSeries;

  }

  @override
  void dispose() {


    
    for (final currentSeries in widget.seriesMap.values) {
      currentSeries.destroy();
    }
    super.dispose();
  }

  double? getOverallMinTime() {
    double? overallMinTime;
    for (Series series in widget.seriesMap.values) {
      double newMinTime = series.getMinTime();

      if (overallMinTime == null) {
        overallMinTime = newMinTime;
      }
      else if (overallMinTime > newMinTime) {
        overallMinTime = newMinTime;
      }
    }
    return overallMinTime;
  }


  double? getOverallMaxTime() {
    double? overallMaxTime;
    for (Series series in widget.seriesMap.values) {
      double newMaxTime = series.getMaxTime();

      if (overallMaxTime == null) {
        overallMaxTime = newMaxTime;
      }
      else if (overallMaxTime < newMaxTime) {
        overallMaxTime = newMaxTime;
      }
    }
    return overallMaxTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) => zoomManager.startScale(details, context.size!.width),

      onScaleUpdate: (details) => setTimeToShow(zoomManager.updateScale(details)),

      child:  LineChart(
      LineChartData(
        minX: minTimeToShow,
        maxX: maxTimeToShow,
        clipData: FlClipData.horizontal(),
        lineBarsData: [
          for (final currentSeries in widget.seriesMap.values)
            LineChartBarData(
              spots: currentSeries.getSpots(),
              isCurved: false,
              color: currentSeries.getRequest().getColor(),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
        ],
      ),
    ));
  }
}

class Series {
  final StreamSubscription subscription;
  List<FlSpot> spots;
  SeriesRequest request;

  Series(this.subscription, this.spots, this.request);

  void setSpots( List<FlSpot> newSpots) {
    spots = newSpots;
  }

  List<FlSpot> getSpots() {
    return spots;
  }

  double getMinTime() {
    return spots.first.x;
  }

  double getMaxTime() {
    return spots.last.x;
  }
  

  void destroy() {
    subscription.cancel();
  }

  SeriesRequest getRequest() {
    return request;
  }
  

}

class ZoomManager {
  ZoomManager(this.onShowTimeChanged);
  
  double? showTimeWidth;
  double? showTimeMax;

  late double startWidth;
  late double startMaxTime;
  late bool startedWithAnyTime;

  double t = 0;
  double focalTime = 0; // 0 → left, 1 → right

  
  final void Function(({double? newMin, double? newMax})) onShowTimeChanged;

  bool hasAnyTime = false;

  double minTime = 0;
  double maxTime = 0;

  double getMinTime() {
    return minTime;
  }

  double getMaxTime() {
    return maxTime;
  }

  void addTimeMeasurement(List<TimeStampedValue> newTimes) {
    for (TimeStampedValue value in newTimes) {
      if (hasAnyTime == false) {
        minTime = value.time;
        maxTime = value.time;
        hasAnyTime = true;
      }
      else if (value.time < minTime) {
        
        minTime = value.time;
        
      } else if (value.time > maxTime) {
        maxTime = value.time;
      }
    }
  }

  void startScale(ScaleStartDetails details, double chartWidth) {



    double? innerShowTimeMax = showTimeMax;
    double? innerShowTimeWidth = showTimeWidth;
    startedWithAnyTime = hasAnyTime;
    
    if (innerShowTimeMax != null) {
      startMaxTime = innerShowTimeMax;
      if (innerShowTimeWidth != null) {
        startWidth = innerShowTimeWidth;
      } else {
        startWidth = maxTime - minTime;
      }
    } else {
      startMaxTime = maxTime;
      startWidth = maxTime - minTime;
    }

    t = details.localFocalPoint.dx / chartWidth; // 0 → left, 1 → right

    focalTime = startMaxTime - startWidth * t;
  }

  
  ({double? newMin, double? newMax}) updateScale(ScaleUpdateDetails details) {
    if (startedWithAnyTime == false) {
      return (newMin: null, newMax: null);
    }
    double proposedWidth = startWidth / details.horizontalScale;
    double proposedMaxValue = focalTime + proposedWidth * t;
  
    showTimeMax = proposedMaxValue;
    showTimeWidth = proposedWidth;
    double? showTimeMin = proposedMaxValue - proposedWidth;

    if (proposedMaxValue > maxTime) {
      showTimeMax = null;
    }

    if (showTimeMin < minTime) {
      showTimeMin = null;
      showTimeWidth = null;
    }

    print("min: $showTimeMin");
    print("max: $showTimeMax");
    print("width: $showTimeWidth");

    print("focalx: $focalTime");

    // return ( newMin: 0, newMax:  1);
    return ( newMin: showTimeMin, newMax:  showTimeMax);
  }
    
}


