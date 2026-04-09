import 'package:flutter/material.dart';

// All the options allowed to have colours picked for them, and there display names
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

// System to assign colours so that new lines tend to get new colours automatically.
// Cycles through the list assigning a new colour to each request in order.
class ColorDistributor {
  // Singleton pattern
  static final ColorDistributor distributor = ColorDistributor._internal();


  // List of options
  List<ColorPickerOption> colorOptions = ColorPickerOption.values;

  // Index of option that will be used for next request
  int colorOptionIndex = 0;

  factory ColorDistributor() {
    return distributor;
  }
  
  ColorDistributor._internal();
  
  // Get the next colour in the list of available colours
  Color getColor() {
    Color result = colorOptions.elementAt(colorOptionIndex).color;

    colorOptionIndex += 1;

    colorOptionIndex %= colorOptions.length;

    return result;
  }
}