import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';
import 'package:silvanus/types/series_request.dart';

class Line extends StatefulWidget {
  final SeriesGroupRequest seriesToShow;

  Map<String, Series> seriesMap = {};

  Line({super.key, required this.seriesToShow});

 

  @override
  State<Line> createState() => _LineState();
  
}

class _LineState extends State<Line> {
  
  
  @override
  initState() {
    super.initState();
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
    

    final sub = Engine.engine.api
        .getTimestampedSeries(key: seriesRequested.getKey())
        .listen((pointsFromRust) {
        setState(() {
          newSpots =  pointsFromRust
              .map((p) => FlSpot(p.time, p.value))
              .toList();
          });
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

  @override
  Widget build(BuildContext context) {


    return LineChart(
      LineChartData(
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
        minY: 0,
        maxY: 1,
      ),
    );
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
  

  void destroy() {
    subscription.cancel();
  }

  SeriesRequest getRequest() {
    return request;
  }
  

}