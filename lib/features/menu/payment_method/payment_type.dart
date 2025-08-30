class PaymentType {
  final int? id;
  final String name;
  PaymentType({this.id, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory PaymentType.fromMap(Map<String, dynamic> m) => PaymentType(id: m['id'], name: m['name']);
}
