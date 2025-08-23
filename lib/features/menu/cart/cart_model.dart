// cart_model.dart
class CartItemModel {
  final int? dbId;
  final String itemId;
  final String name;
  final double price;
  final String? selectedOption;
  final String? selectedTable;
  final String orderType;
  final String? imageUrl; // NEW
  final int quantity;

  CartItemModel({
    this.dbId,
    required this.itemId,
    required this.name,
    required this.price,
    this.selectedOption,
    this.selectedTable,
    required this.orderType,
    this.imageUrl,
    this.quantity = 1,
  });

  CartItemModel copyWith({int? dbId, int? quantity, String? selectedTable}) {
    return CartItemModel(
      dbId: dbId ?? this.dbId,
      itemId: itemId,
      name: name,
      price: price,
      selectedOption: selectedOption,
      selectedTable: selectedTable,
      orderType: orderType,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': dbId,
      'itemId': itemId,
      'name': name,
      'price': price,
      'selectedOption': selectedOption,
      'selectedTable': selectedTable,
      'orderType': orderType,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      dbId: map['id'] as int?,
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      selectedOption: map['selectedOption'] as String?,
      selectedTable: map['selectedTable'] as String?,
      orderType: map['orderType'] as String,
      imageUrl: map['imageUrl'] as String?,
      quantity: map['quantity'] as int,
    );
  }
}
