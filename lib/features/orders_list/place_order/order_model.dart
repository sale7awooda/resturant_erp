// lib/features/orders_list/place_order/order_model.dart
import 'dart:convert';
import 'package:starter_template/features/menu/cart/cart_model.dart';

class OrderModel {
  final int? id;
  final String orderType; // dinein, takeaway, delivery
  final String? paymentType; // null when dinein "sent to kitchen"
  final double totalAmount;
  final int totalItems;
  final String? transactionId;
  final String? tableName;
  final String? deliveryAddress;
  final DateTime createdAt;
  final List<CartItemModel> items;
  final String status; // placed, sent_to_kitchen, completed, canceled

  OrderModel({
    this.id,
    required this.orderType,
    this.paymentType,
    required this.totalAmount,
    required this.totalItems,
    this.transactionId,
    this.tableName,
    this.deliveryAddress,
    required this.createdAt,
    required this.items,
    this.status = 'placed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderType': orderType,
      'paymentType': paymentType ?? '',
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'transactionId': transactionId,
      'tableName': tableName,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt.toIso8601String(),
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map['items'] as String) as List<dynamic>;
    return OrderModel(
      id: map['id'] as int?,
      orderType: map['orderType'] as String,
      paymentType: (map['paymentType'] as String?)?.isEmpty == true
          ? null
          : map['paymentType'] as String?,
      totalAmount: map['totalAmount'] as double,
      totalItems: map['totalItems'] as int,
      transactionId: map['transactionId'] as String?,
      tableName: map['tableName'] as String?,
      deliveryAddress: map['deliveryAddress'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
      items: decoded.map((e) => CartItemModel.fromMap(e)).toList(),
      status: map['status'] as String,
    );
  }

  OrderModel copyWith({
    int? id,
    String? orderType,
    String? paymentType,
    double? totalAmount,
    int? totalItems,
    String? transactionId,
    String? tableName,
    String? deliveryAddress,
    DateTime? createdAt,
    List<CartItemModel>? items,
    String? status,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderType: orderType ?? this.orderType,
      paymentType: paymentType ?? this.paymentType,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      transactionId: transactionId ?? this.transactionId,
      tableName: tableName ?? this.tableName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }
}
