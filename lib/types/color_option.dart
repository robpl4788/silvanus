import 'package:flutter/material.dart';


enum ColorPickerOption {
  red(label: "Red", color: Colors.red),
  green(label: "Green", color: Colors.green),
  blue(label: "Blue", color: Colors.blue),
  black(label: "Black", color: Colors.black);

  const ColorPickerOption ( {
    required this.label,
    required this.color
  });
  
  final Color color;
  final String label;
}

class ColorDistributor {
  static final ColorDistributor distributor = ColorDistributor._internal();

  List<ColorPickerOption> colorOptions = ColorPickerOption.values;
  int colorOptionIndex = 0;

  factory ColorDistributor() {
    return distributor;
  }
  
  ColorDistributor._internal();
  
  Color getColor() {
    Color result = colorOptions.elementAt(colorOptionIndex).color;

    colorOptionIndex += 1;

    colorOptionIndex %= colorOptions.length;

    return result;
  }
}