class RestaurantTable {
  final int? id;
  final String name;
  RestaurantTable({this.id, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory RestaurantTable.fromMap(Map<String, dynamic> m) => RestaurantTable(id: m['id'], name: m['name']);
}
