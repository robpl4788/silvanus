
import 'package:flutter/material.dart';
import 'package:silvanus/src/rust/api/api.dart';

class SourceSelector extends StatefulWidget{

  final Future<void> Function(Future<ArcEngine>) onSelectionChanged;

  const SourceSelector({super.key, required this.onSelectionChanged});
  
  @override
  State<SourceSelector> createState() => SourceSelectorState();
}

class SourceSelectorState extends State<SourceSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
            dropdownMenuEntries:  [
              DropdownMenuEntry(value: SourceOptions.random, label: SourceOptions.random.label),
              DropdownMenuEntry(value: SourceOptions.csv, label: SourceOptions.csv.label) ,
              DropdownMenuEntry(value: SourceOptions.none, label: SourceOptions.none.label), ] ,
            onSelected: (dynamic value) {
              if (value is SourceOptions) {
                Future<ArcEngine> newEngineFuture;
                // Initialise a new engine based on the selected option
                switch (value) {
                  case SourceOptions.random:
                    newEngineFuture =  loadTest();
                    break;
                  case SourceOptions.csv:
                    newEngineFuture = loadCsv(csvPath: "C:\\silvanus\\rust\\src\\parser\\test.csv");
                    break;
                  case SourceOptions.none:
                    newEngineFuture = loadNone();
                    break;
                }
                widget.onSelectionChanged(newEngineFuture);
              }
            }
            );
  }
}

// Currently available options
enum SourceOptions {
  random(label: "Random"),
  csv(label: "CSV"),
  none(label: "none");

  const SourceOptions({required this.label});

  final String label;

}