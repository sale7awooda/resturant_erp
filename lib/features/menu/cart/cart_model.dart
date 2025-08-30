import 'package:starter_template/features/orders/order_model.dart';

class CartItemModel {
  final int? id;
  final String itemId;
  final String name;
  final double price;
  // final bool? hasOption;
  final String? selectedOption;
  final String? selectedTable;
  final String orderType;
  final String? imageUrl;
  final int quantity;
  final String? source;

  CartItemModel({
    this.id,
    required this.itemId,
    required this.name,
    required this.price,
    // this.hasOption,
    this.selectedOption,
    this.selectedTable,
    required this.orderType,
    this.imageUrl,
    required this.quantity,
    this.source,
  });

  CartItemModel copyWith({
    int? id,
    String? itemId,
    String? name,
    double? price,
    String? selectedOption,
    // bool? hasOption,
    String? selectedTable,
    String? orderType,
    String? imageUrl,
    int? quantity,
    String? source,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      // hasOption: hasOption ?? this.hasOption,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedTable: selectedTable ?? this.selectedTable,
      orderType: orderType ?? this.orderType,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      source: source ?? this.source,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as int?,
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      // hasOption: map['hasOption'] as bool,
      selectedOption: map['selectedOption'] as String?,
      selectedTable: map['selectedTable'] as String?,
      orderType: map['orderType'] as String,
      imageUrl: map['imageUrl'] as String?,
      quantity: map['quantity'] as int,
      source: map['source'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'price': price,
      // 'hasOption': hasOption,
      'selectedOption': selectedOption,
      'selectedTable': selectedTable,
      'orderType': orderType,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'source': source ?? 'normal',
    };
  }

  OrderItemModel toOrderItem(int orderId) {
    return OrderItemModel(
      orderId: orderId,
      menuItemId: itemId,
      itemName: name,
      quantity: quantity,
      // hasOption: hasOption?? false,
      selectedOption: selectedOption ?? '',
      price: price,
    );
  }

  factory CartItemModel.fromOrderItem(OrderItemModel item, String orderType) {
    return CartItemModel(
      itemId: item.menuItemId,
      name: item.itemName,
      price: item.price,
      quantity: item.quantity,
      orderType: orderType,
      // hasOption: item.hasOption,
      selectedOption: item.selectedOption,
      source: 'prefill',
    );
  }
}
