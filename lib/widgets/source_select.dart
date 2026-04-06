
import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';

class SourceSelector extends StatefulWidget{

  final void Function(SourceOptions src) onSelectionChanged;

  const SourceSelector({super.key, required this.onSelectionChanged});
  
  @override
  State<SourceSelector> createState() => SourceSelectorState();
}

class SourceSelectorState extends State<SourceSelector> {

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
            dropdownMenuEntries:  [
              DropdownMenuEntry(value: SourceOptions.random, label: SourceOptions.random.label),
              DropdownMenuEntry(value: SourceOptions.csv, label: SourceOptions.csv.label), ] ,
            onSelected: (dynamic value) {
              if (value is SourceOptions) {
                switch (value) {
                  case SourceOptions.random:
                    Engine.engine.api.loadTest();
                    print("select rand");
                    break;
                  case SourceOptions.csv:
                    print("select csv");
                    Engine.engine.api.loadCsv(csvPath: "C:\\silvanus\\rust\\src\\parser\\test.csv");
                    break;
                  case SourceOptions.none:
                    print("select none which does nothing atm");
                    break;
                }
              }
            }
            );
  }
}


enum SourceOptions {
  random(label: "Random"),
  csv(label: "CSV"),
  none(label: "none");

  const SourceOptions({required this.label});

  final String label;

}