class CartItemModel {
  final int? dbId;
  final String itemId;
  final String name;
  final double price;
  final String? selectedOption;
  final String orderType;
  final String? imageUrl;
  final int quantity;

  CartItemModel({
    this.dbId,
    required this.itemId,
    required this.name,
    required this.price,
    this.selectedOption,
    required this.orderType,
    this.imageUrl,
    this.quantity = 1,
  });

  CartItemModel copyWith({
    int? dbId,
    int? quantity,
  }) {
    return CartItemModel(
      dbId: dbId ?? this.dbId,
      itemId: itemId,
      name: name,
      price: price,
      selectedOption: selectedOption,
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
      orderType: map['orderType'] as String,
      imageUrl: map['imageUrl'] as String?,
      quantity: map['quantity'] as int,
    );
  }

  /// Build CartItemModel from an existing CartItemModel (used for pre-filling cart from an order)
  factory CartItemModel.fromOrderItem(CartItemModel item, String orderType) {
    return CartItemModel(
      itemId: item.itemId,
      name: item.name,
      price: item.price,
      selectedOption: item.selectedOption,
      orderType: orderType,
      imageUrl: item.imageUrl,
      quantity: item.quantity,
    );
  }
}
