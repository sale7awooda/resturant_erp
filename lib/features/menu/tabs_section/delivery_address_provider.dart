import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Address {
  east,
  matar,
  north,
  wihda,
  alsoog,
  damar,
  barber,
  khelewa,
  other
}

// List of available categories
final deliveryAddressProvider = Provider<List<String>>((ref) {
  return [
    Address.east.name,
    Address.matar.name,
    Address.north.name,
    Address.wihda.name,
    Address.alsoog.name,
    Address.damar.name,
    Address.barber.name,
    Address.khelewa.name,
    Address.other.name
  ];
});

// Selected table ('all menu' at first)
final selectedDeliveryAddressProvider = StateProvider<String?>((ref) => null);
