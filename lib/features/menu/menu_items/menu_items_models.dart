class MenuItemModel {
  final String id;
  final String name;
  final String categ;
  final double price;
  final List<String> options; // single-choice options (e.g., size)

  MenuItemModel({
    required this.id,
    required this.name,
    required this.categ,
    required this.price,
    required this.options,
  });
}
