import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 4,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            color: Colors.blue,
            barWidth: 2,
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
            ],
          ),
        ],
      ),
    );
  }
}
