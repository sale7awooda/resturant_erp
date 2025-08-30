// ignore_for_file: public_member_api_docs, sort_constructors_first
class MenuItem {
  final int? id;
  final String name;
  final double price;
  final String? category;
  final bool hasOption;
  final String? options;
  // final String? description;
  final String? imageUrl;
  MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.category,
    required this.hasOption,
    this.options,
    // this.description,
    this.imageUrl,
  });
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'hasOption': hasOption,
        'options': options,
        // 'description': description,
        'imageUrl': imageUrl
      };
  factory MenuItem.fromMap(Map<String, dynamic> m) => MenuItem(
        id: m['id'],
        name: m['name'],
        price: m['price'],
        category: m['category'],
        hasOption: m['hasOption'],
        options: m['options'],
        // description: m['description'],
        imageUrl: m['imageUrl'],
      );
}
