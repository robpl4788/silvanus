

import 'package:flutter/material.dart';

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

  void addFreshKeys(List<String> freshKeys) {
    for (final key in freshKeys) {
      SeriesRequest newRequest = SeriesRequest(key);
      addRequest(newRequest);
    }
  }

  List<SeriesRequest> getAllRequests() {
    List<SeriesRequest> allRequests = group.values.toList();
    allRequests.sort((a, b) => a.getKey().compareTo(b.getKey()));
    return allRequests;
  }

  SeriesGroupRequest.empty();
}

class SeriesRequest {
  final String name;
  Color color = Colors.blue;
  
  SeriesRequest(this.name);

  String getKey() {
    return name;
  }

  Color getColor() {
    return color;
  }

  void setColor (Color newColor) {

    color = newColor;
  }
}