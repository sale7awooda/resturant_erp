import 'dart:convert';
import 'package:starter_template/features/menu/cart/cart_model.dart';

enum OrderStatus { pending, completed, cancelled }

class OrderModel {
  final int? id;
  final String orderType; // dinein, takeaway, delivery
  final String orderStatus; // preparing, complete, canceled, pending_payment...
  final String paymentStatus; // pending, paid, failed
  final String? paymentType; // cash, card, bank
  final String? paymentId; // txnId or "cash"
  final double totalAmount;
  final int totalItems;
  final String? transactionId;
  final String? tableName;
  // Delivery-only
  final String? deliveryAddress;
  final String? deliveryOwner;
  final String? deliveryPhone;
  final String? deliveryInstructions;

  final DateTime createdAt;
  final List<CartItemModel> items;

  OrderModel({
    this.id,
    required this.orderType,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentType,
    this.paymentId,
    required this.totalAmount,
    required this.totalItems,
    this.transactionId,
    this.tableName,
    this.deliveryAddress,
    this.deliveryOwner,
    this.deliveryPhone,
    this.deliveryInstructions,
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderType': orderType,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentType': paymentType,
      'paymentId': paymentId,
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'transactionId': transactionId,
      'tableName': tableName,
      'deliveryAddress': deliveryAddress,
      'deliveryOwner': deliveryOwner,
      'deliveryPhone': deliveryPhone,
      'deliveryInstructions': deliveryInstructions,
      'createdAt': createdAt.toIso8601String(),
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map['items'] as String) as List<dynamic>;
    return OrderModel(
      id: map['id'] as int?,
      orderType: map['orderType'] as String,
      orderStatus: map['orderStatus'] as String,
      paymentStatus: map['paymentStatus'] as String,
      paymentType: map['paymentType'] as String?,
      paymentId: map['paymentId'] as String?,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      totalItems: map['totalItems'] as int,
      transactionId: map['transactionId'] as String?,
      tableName: map['tableName'] as String?,
      deliveryAddress: map['deliveryAddress'] as String?,
      deliveryOwner: map['deliveryOwner'] as String?,
      deliveryPhone: map['deliveryPhone'] as String?,
      deliveryInstructions: map['deliveryInstructions'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
      items: decoded.map((e) => CartItemModel.fromMap(e)).toList(),
    );
  }

  OrderModel copyWith({
    int? id,
    String? orderType,
    String? orderStatus,
    String? paymentStatus,
    String? paymentType,
    String? paymentId,
    double? totalAmount,
    int? totalItems,
    String? transactionId,
    String? tableName,
    String? deliveryAddress,
    String? deliveryOwner,
    String? deliveryPhone,
    String? deliveryInstructions,
    DateTime? createdAt,
    List<CartItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderType: orderType ?? this.orderType,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      paymentId: paymentId ?? this.paymentId,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      transactionId: transactionId ?? this.transactionId,
      tableName: tableName ?? this.tableName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryOwner: deliveryOwner ?? this.deliveryOwner,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
