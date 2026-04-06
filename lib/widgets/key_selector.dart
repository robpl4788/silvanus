import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';
import 'package:silvanus/types/color_option.dart';
import 'package:silvanus/types/series_request.dart';

class KeySelector extends StatefulWidget{

  final void Function(SeriesGroupRequest selected) onSelectionChanged;

  const KeySelector({super.key, required this.onSelectionChanged});
  
  @override
  State<KeySelector> createState() => KeySelectorState();
}

class KeySelectorState extends State<KeySelector> {
  SeriesGroupRequest options = SeriesGroupRequest.empty();
  final SeriesGroupRequest selected = SeriesGroupRequest.empty();

  @override
  void initState() {
    super.initState();
    Engine.engine.api.loadTest();

    Engine.engine.api.getAvailableKeys().listen((keys){
      setState(() {
        options.addFreshKeys(keys);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final request in options.getAllRequests())
          Row(
            children: [
              if (selected.contains(request)) colourPicker(request),
              Expanded(child: CheckboxListTile(
                title: Text(request.name),
                value: selected.contains(request),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      selected.addRequest(request);
                    } else {
                      selected.removeRequest(request);
                    }
                  });

                  widget.onSelectionChanged(selected);
                },
              )),
      ],)]
    );
  }

  DropdownMenu colourPicker(SeriesRequest request) {
    return  DropdownMenu(
            dropdownMenuEntries: [
              for (final option in ColorPickerOption.values) DropdownMenuEntry(value: option.color, label: option.label) ],
            onSelected: (dynamic value) {
              if (value is Color) {
                request.setColor(value);
                setState(() {
                  selected.addRequest(request);
                  options.addRequest(request);
                } ); } },
            initialSelection: request.getColor(),
            );
  }
}

