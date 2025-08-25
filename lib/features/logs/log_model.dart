// lib/features/logs/log_model.dart
class LogModel {
  final int? id;
  final String action;        // e.g. cart_add, order_placed, order_canceled
  final String entity;        // e.g. cart, order, user
  final String? entityId;     // e.g. dbId, orderId
  final String details;       // human readable
  final String userId;
  final DateTime timestamp;

  LogModel({
    this.id,
    required this.action,
    required this.entity,
    this.entityId,
    required this.details,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action,
        'entity': entity,
        'entityId': entityId,
        'details': details,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LogModel.fromMap(Map<String, dynamic> map) => LogModel(
        id: map['id'] as int?,
        action: map['action'] as String,
        entity: map['entity'] as String,
        entityId: map['entityId'] as String?,
        details: map['details'] as String,
        userId: map['userId'] as String,
        timestamp: DateTime.parse(map['timestamp']),
      );
}
