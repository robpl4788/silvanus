import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/src/rust/api/simple.dart';

class SimpleLineChart extends StatefulWidget {
  const SimpleLineChart({super.key});

  @override
  State<SimpleLineChart> createState() => _LiveChartState();
}

class _LiveChartState extends State<SimpleLineChart> {
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();

    // Listen to Rust stream
    getTestData().listen((pointsFromRust) {
      setState(() {
        // Replace the entire dataset
        spots = pointsFromRust
            .map((p) => FlSpot(p.x, p.y))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
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
