import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
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
  
  double minTimeToShow = 0;
  double maxTimeToShow = 0;
  late final ZoomManager zoomManager;

  void setTimeToShow(({double newMin, double newMax}) newTime) {
    // print("setting: $minTimeToShow -> $maxTimeToShow");
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
    return Listener(
      onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()) {
              zoomManager.updateZoom(-event.scrollDelta.dy / 50);

            } else {
              zoomManager.startZoom(event.localPosition.dx, context.size!.width);
              zoomManager.updatePan(-event.scrollDelta.dx / 1000);
            }
          }
        },
      child: GestureDetector(
      onVerticalDragStart: (details) => zoomManager.startZoom(details.localPosition.dx, context.size!.width),
      onVerticalDragUpdate: (details) => zoomManager.updateZoom((details.primaryDelta ?? 0) / 50),
      onHorizontalDragUpdate: (details) => zoomManager.updatePan((details.primaryDelta ?? 0) / 50),

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
    )));
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
  
  bool pinnedToMax = false;
  bool pinnedToMin = false;

  double showTimeMin = 0.3;
  double showTimeMax = 0.5;

  bool hasAnyTime = false;

  double minTime = 0;
  double maxTime = 0;

  double focalTime = 0;
  double t = 0;

  
  final void Function(({double newMin, double newMax})) onShowTimeChanged;


  double getMinTime() {
    return minTime;
  }

  double getMaxTime() {
    return maxTime;
  }

  void addTimeMeasurement(List<TimeStampedValue> newTimes) {

    onShowTimeChanged((newMax: showTimeMax, newMin: 0.2));

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

    if (pinnedToMax && pinnedToMin) {
      showTimeMax = maxTime;
      showTimeMin = minTime;

    } else if (pinnedToMin) {
      double width = showTimeMax - showTimeMin;
      showTimeMin = minTime;
      showTimeMax = minTime + width;
      if (showTimeMax > maxTime) {
        showTimeMax = maxTime;
      }
    } else if (pinnedToMax) {
      double width = showTimeMax - showTimeMin;
      showTimeMax = maxTime;
      showTimeMin = maxTime - width;
      if (showTimeMin < minTime) {
        showTimeMin = minTime;
      }
    }
    onShowTimeChanged((newMax: showTimeMax, newMin: showTimeMin));
  }


  void startZoom(double localX, double chartWidth) {
    t = localX / chartWidth; // 0 → left, 1 → right
    // print("t: $t");
    double width = showTimeMax - showTimeMin;

    focalTime = showTimeMin + width * t;

  }
  
  void updateZoom(double distance) {
    if (hasAnyTime) {
      double width = showTimeMax - showTimeMin;

      double scaleFactor = -distance;
      double proposedWidth = width *  pow(2, scaleFactor);
      // print("scale factor: $scaleFactor");
      // print("width: $proposedWidth");
      double proposedMaxValue = focalTime + proposedWidth * t;
    
      showTimeMax = proposedMaxValue;
      showTimeMin = proposedMaxValue - proposedWidth;

      pinnedToMax = false;
      pinnedToMin = false;


      if (showTimeMax > maxTime) {
        showTimeMax = maxTime;
        showTimeMin = showTimeMax - proposedWidth;
        pinnedToMax = true;
        if (showTimeMin < minTime) {
          showTimeMin = minTime;
          pinnedToMin = true;
        }
      }
      else if (showTimeMin < minTime) {
        showTimeMin = minTime;
        showTimeMax = showTimeMin + proposedWidth;
        pinnedToMin = true;
        if (showTimeMax > maxTime) {
          showTimeMax = maxTime;
          pinnedToMax = true;
        }
      }

      onShowTimeChanged(( newMin: showTimeMin, newMax:  showTimeMax));
      assert(showTimeMin < showTimeMax);
      // return ( newMin: 0, newMax:  1);
    }
  }


  void updatePan(double distance) {
    // print("update pan: $distance");
    if (hasAnyTime) {
      double width = showTimeMax - showTimeMin;
      double proposedMove = distance * width;
      double proposedMin = showTimeMin - proposedMove;
      double proposedMax = showTimeMax - proposedMove;

      if (proposedMax > maxTime) {
        showTimeMax = maxTime;
        showTimeMin = maxTime - width;
        pinnedToMax = true;
      } else if (proposedMin < minTime) {
        showTimeMax = minTime + width;
        showTimeMin = minTime;
        pinnedToMin = true;
      } else {
        showTimeMax = proposedMax;
        showTimeMin = proposedMin;
        pinnedToMax = false;
        pinnedToMin = false;
      }

      // print("min: $showTimeMin");
      // print("max: $showTimeMax");
    
      // return ( newMin: 0, newMax:  1);
      onShowTimeChanged(( newMin: showTimeMin, newMax:  showTimeMax));
    }
  }  
}


