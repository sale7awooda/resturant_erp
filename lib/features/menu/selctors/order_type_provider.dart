import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderType { takeaway, dinein, delivery }

extension OrderTypeName on OrderType {
  String get name => switch (this) {
        OrderType.takeaway => 'takeaway',
        OrderType.dinein => 'dinein',
        OrderType.delivery => 'delivery',
      };
}

final orderTypeProvider = StateProvider<OrderType>((ref) => OrderType.takeaway);
