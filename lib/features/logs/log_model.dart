class LogModel {
  final int? id;
  final String action;    // 'create_order' | 'update_order' | 'cancel_order' | ...
  final String details;   // free-form JSON or text
  final String userId;    // who did it
  final DateTime timestamp;

  LogModel({
    this.id,
    required this.action,
    required this.details,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action,
        'details': details,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LogModel.fromMap(Map<String, dynamic> m) => LogModel(
        id: m['id'] as int?,
        action: m['action'] as String,
        details: m['details'] as String,
        userId: m['userId'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
}
