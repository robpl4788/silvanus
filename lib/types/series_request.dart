

import 'package:flutter/material.dart';
import 'package:silvanus/types/color_option.dart';

// A group of series requested, effectively a wrapper for a map
class SeriesGroupRequest {
  Map<String, SeriesRequest> group = {};


  void addRequest(SeriesRequest newRequest) {
    group[newRequest.getKey()] = newRequest;
  }

  SeriesRequest? getRequest(String key) {
    return group[key];
  }

  void removeRequest(SeriesRequest toRemove) {
    group.remove(toRemove.getKey());
  }

  bool contains(SeriesRequest checkIfContains) {
    return group.containsKey(checkIfContains.getKey());
  }

  bool containsKey(String checkIfContainsKey) {
    return group.containsKey(checkIfContainsKey);
  }

  // Add a set of new requests based on the supplied keys
  void addFreshKeys(List<String> freshKeys) {
    for (final key in freshKeys) {
      if (containsKey(key) == false) {
        SeriesRequest newRequest = SeriesRequest(key);
        addRequest(newRequest);
      }
    }
  }

  // Get all the current requests as a list, sorted alphabetically
  List<SeriesRequest> getAllRequests() {
    List<SeriesRequest> allRequests = group.values.toList();
    allRequests.sort((a, b) => a.getKey().compareTo(b.getKey()));
    return allRequests;
  }

  SeriesGroupRequest.empty();
}


// An individual series request
class SeriesRequest {
  final String name;
  Color color = Colors.blue;

  bool assignedColor = false;
  
  SeriesRequest(this.name);

  String getKey() {
    return name;
  }

  // Get the requested colour. If one hasn't been assigned it will get one from the color distributor
  Color getColor() {
    if (assignedColor == false) {
      setColor(ColorDistributor.distributor.getColor());
    }
    return color;
  }

  void setColor (Color newColor) {
    assignedColor = true;
    color = newColor;
  }
}

