import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';

class SimpleLineChart extends StatefulWidget {
  const SimpleLineChart({super.key});

  @override
  State<SimpleLineChart> createState() => _LiveChartState();
}

class _LiveChartState extends State<SimpleLineChart> {
  List<FlSpot> spots = [];

  @override
  initState() {
    super.initState();
  
    updatePoints();
  }

  Future<void> updatePoints() async {
    Engine.engine.api.loadTest();
    // api.loadCsv(csvPath: "C:\\silvanus\\rust\\src\\parser\\test.csv");

    Engine.engine.api.getTimestampedSeries(key: "accel_x").listen((pointsFromRust){
      setState(() {
        // Replace the entire dataset
        spots = pointsFromRust
            .map((p) => FlSpot(p.time, p.value))
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
