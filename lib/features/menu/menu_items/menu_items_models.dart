// ignore_for_file: public_member_api_docs, sort_constructors_first
class MenuItemModel {
  final String id;
  final String name;
  final String img;
  final String categ;
  final double price;
  // final bool hasOption;
  final List<String>? options; // single-choice options (e.g., size)

  MenuItemModel({
    required this.id,
    required this.name,
    required this.img,
    required this.categ,
    required this.price,
    // required this.hasOption,
     this.options,
  });
}
