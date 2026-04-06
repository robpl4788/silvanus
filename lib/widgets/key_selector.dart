import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';

class KeySelector extends StatefulWidget{

  final void Function(Set<String> selected) onSelectionChanged;

  const KeySelector({super.key, required this.onSelectionChanged});
  
  @override
  State<KeySelector> createState() => KeySelectorState();
}

class KeySelectorState extends State<KeySelector> {
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    Engine.engine.api.loadTest();

    Engine.engine.api.getAvailableKeys().listen((keys){
      setState(() {
        // Replace the entire dataset
        options = keys;
        options.sort();
      });
    });
  }

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final item in options)
          CheckboxListTile(
            title: Text(item),
            value: selected.contains(item),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  selected.add(item);
                } else {
                  selected.remove(item);
                }
              });

              widget.onSelectionChanged(selected);
            },
          ),
      ],
    );
  }

  DropdownMenu colourPicker() {
    return DropdownMenu(dropdownMenuEntries: [
      DropdownMenuEntry(value: "red", label: "red"),
      DropdownMenuEntry(value: "blue", label: "blue"),
      DropdownMenuEntry(value: "green", label: "green"),
    ]);
  }
}