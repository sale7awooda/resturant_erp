class Address {
  final int? id;
  final String name;
  final String? details;
  Address({this.id, required this.name, this.details});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'details': details};
  factory Address.fromMap(Map<String, dynamic> m) => Address(id: m['id'], name: m['name'], details: m['details']);
}
