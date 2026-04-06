import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';

class Line extends StatefulWidget {
  final List<String> keysToShow;

  Map<String, Series> seriesMap = {};

  Line({super.key, required this.keysToShow});

 

  @override
  State<Line> createState() => _LineState();
  
}

class _LineState extends State<Line> {
  
  
  @override
  initState() {
    super.initState();
    for (final key in widget.keysToShow) {
      _subscribeToSeries(key);

    }
  }

  @override
  void didUpdateWidget(covariant Line oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.seriesMap.addEntries(oldWidget.seriesMap.entries);

    // If key currently in the set and shouldnt be remove it
    List<String> startingKeys = widget.seriesMap.keys.toList();
    for (final key in startingKeys) {
      if (widget.keysToShow.contains(key) == false) {
        widget.seriesMap[key]?.destroy();
        widget.seriesMap.remove(key);
      }
    }

    // If the key isn't in the set and should be add it
    for (final key in widget.keysToShow)   {
      if (widget.seriesMap.containsKey(key) == false) {
        _subscribeToSeries(key);
      }
    }
  }

  void _subscribeToSeries(String key) {

  
    List<FlSpot> newSpots = [];
    

    final sub = Engine.engine.api
        .getTimestampedSeries(key: key)
        .listen((pointsFromRust) {
        setState(() {
          newSpots =  pointsFromRust
              .map((p) => FlSpot(p.time, p.value))
              .toList();
          });
          widget.seriesMap[key]?.setSpots(newSpots);

        });
      Series newSeries = Series(sub, newSpots);
      widget.seriesMap[key] = newSeries;

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
              color: Colors.blue,
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

  Series(this.subscription, this.spots);

  void setSpots( List<FlSpot> newSpots) {
    spots = newSpots;
  }

  List<FlSpot> getSpots() {
    return spots;
  }
  

  void destroy() {
    subscription.cancel();
  }
  

}