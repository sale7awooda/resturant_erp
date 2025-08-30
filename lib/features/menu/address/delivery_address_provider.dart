import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Location {
  final String name;
  final int cost;

  Location({required this.name, required this.cost});
}

Location east = Location(name: "East", cost: 5);
Location matar = Location(name: "Matar", cost: 6);
Location north = Location(name: "North", cost: 5);
Location wihda = Location(name: "Wihda", cost: 2);
Location alsoog = Location(name: "Alsoog", cost: 15);
Location damar = Location(name: "Damar", cost: 3);
Location barber = Location(name: "Barber", cost: 20);
Location khelewa = Location(name: "Khelewa", cost: 4);
Location other = Location(name: "Other", cost: 10);

// List of available categories
final deliveryAddressProvider = Provider<List<Location>>((ref) {
  // final address = Address();
  return [east, matar, north, wihda, alsoog, damar, barber, khelewa, other];
});

// Selected table ('all menu' at first)
final selectedDeliveryAddressProvider = StateProvider<Location?>((ref) => null);
