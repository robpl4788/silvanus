
import 'package:flutter/material.dart';
import 'package:silvanus/types/series_request.dart';
import 'package:silvanus/widgets/charts/line.dart';
import 'package:silvanus/widgets/key_selector.dart';

class AnalysisTab extends StatefulWidget{
  const AnalysisTab({super.key});

  @override
  State<StatefulWidget> createState() => _AnalysisTabState();

}

class _AnalysisTabState extends State<AnalysisTab> {
  SeriesGroupRequest selectedSeries = SeriesGroupRequest.empty();

  @override
  Widget build(BuildContext context) {


    return Row(
      children: [
        // Left side: selector
        Expanded(
          flex: 1,
          child: KeySelector(
            onSelectionChanged: (newSelection) {
              setState(() {
                selectedSeries = newSelection;
              });
            },
          ),
        ),

        // Right side: graph
        Expanded(
          flex: 2,
          child: Line(
            seriesToShow: selectedSeries,
          ),
        ),
      ],
    );
  }
}