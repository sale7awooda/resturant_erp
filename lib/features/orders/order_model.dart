import 'package:starter_template/features/menu/cart/cart_model.dart';

enum OrderStatus { pending, completed, cancelled }

class OrderModel {
  final int? id;
  final String orderType; // dineIn, takeaway, delivery
  final String? tableName;
  final String? deliveryAddress; // for delivery
  final double totalAmount;
  final int totalItems;
  final int? deliveryFee; // for delivery
  final String paymentStatus; // pending, paid, failed
  final String paymentMethod; // cash, card, wallet
  final String orderStatus; // pending, completed, cancelled
  final DateTime createdAt;
  final List<OrderItemModel> orderItems;
  final String? specialOrderId;

  OrderModel({
    this.id,
    this.deliveryAddress,
    required this.orderType,
    this.tableName,
    required this.totalAmount,
    this.deliveryFee,
    required this.totalItems,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderStatus,
    required this.createdAt,
    required this.orderItems,
    this.specialOrderId,
  });

  OrderModel copyWith({
    int? id,
    String? orderType,
    String? tableName,
    String? deliveryAddress,
    double? totalAmount,
    int? totalItems,
    int? deliveryFee,
    String? paymentStatus,
    String? paymentMethod,
    String? orderStatus,
    DateTime? createdAt,
    List<OrderItemModel>? orderItems,
    String? specialOrderId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderType: orderType ?? this.orderType,
      tableName: tableName ?? tableName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      orderItems: orderItems ?? this.orderItems,
      specialOrderId: specialOrderId ?? this.specialOrderId,
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map,
      {List<OrderItemModel>? orderItems}) {
    return OrderModel(
      id: map['id'] as int?,
      orderType: map['orderType'] as String,
      tableName: map['tableName'] as String?,
      deliveryAddress: map['deliveryAddress'] as String?,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      totalItems: map['totalItems'] as int? ?? 0,
      deliveryFee: map['deliveryFee'] as int? ?? 0,
      paymentStatus: map['paymentStatus'] as String,
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
      orderStatus: map['orderStatus'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      specialOrderId: map['specialOrderId'] as String?,
      orderItems: orderItems ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderType': orderType,
      'tableName': tableName,
      'deliveryAddress': deliveryAddress,
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'deliveryFee': deliveryFee,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'createdAt': createdAt.toIso8601String(),
      'specialOrderId': specialOrderId,
    };
  }
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final String menuItemId;
  final String itemName;
  final int quantity;
  // final bool hasOption;
  final String selectedOption;
  final double price;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.menuItemId,
    required this.itemName,
    required this.quantity,
    // required this.hasOption,
    required this.selectedOption,
    required this.price,
  });

  OrderItemModel copyWith({
    int? id,
    int? orderId,
    String? menuItemId,
    String? itemName,
    int? quantity,
    // bool? hasOption,
    String? selectedOption,
    double? price,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      // hasOption:hasOption??this.hasOption,
      selectedOption: selectedOption ?? this.selectedOption,
      price: price ?? this.price,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['orderId'] as int,
      menuItemId: map['menuItemId'] as String,
      itemName: map['itemName'] as String,
      quantity: map['quantity'] as int,
      // hasOption:map['hasOption']as bool,
      selectedOption: map['selectedOption'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'menuItemId': menuItemId,
      'itemName': itemName,
      'quantity': quantity,
      // 'hasOption':hasOption,
      'selectedOption': selectedOption,
      'price': price,
    };
  }

  CartItemModel toCartItem(String orderType) {
    return CartItemModel.fromOrderItem(this, orderType);
  }
}
