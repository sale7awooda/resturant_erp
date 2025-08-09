class CartItemModel {
  final int? dbId; // primary key in sqlite (nullable while in-memory)
  final String itemId; // menu item id
  final String name;
  final double price;
  final String? selectedOption;
  final int quantity;

  CartItemModel({
    this.dbId,
    required this.itemId,
    required this.name,
    required this.price,
    this.selectedOption,
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
      quantity: map['quantity'] as int,
    );
  }
}
