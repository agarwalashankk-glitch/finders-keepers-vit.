import 'item_status.dart';

class ItemEventModel {
  final String id;
  final String itemId;
  final String eventType; // 'reported', 'claim_submitted', 'claim_reviewed', 'verified', 'returned', 'status_change'
  final ItemStatus previousStatus;
  final ItemStatus newStatus;
  final String triggeredByUserId;
  final String triggeredByUserName;
  final String notes;
  final DateTime timestamp;

  const ItemEventModel({
    required this.id,
    required this.itemId,
    required this.eventType,
    required this.previousStatus,
    required this.newStatus,
    required this.triggeredByUserId,
    required this.triggeredByUserName,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'eventType': eventType,
      'previousStatus': previousStatus.name,
      'newStatus': newStatus.name,
      'triggeredByUserId': triggeredByUserId,
      'triggeredByUserName': triggeredByUserName,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ItemEventModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemEventModel(
      id: id,
      itemId: map['itemId'] as String? ?? '',
      eventType: map['eventType'] as String? ?? 'status_change',
      previousStatus: ItemStatus.fromString(map['previousStatus'] as String? ?? 'lost'),
      newStatus: ItemStatus.fromString(map['newStatus'] as String? ?? 'lost'),
      triggeredByUserId: map['triggeredByUserId'] as String? ?? '',
      triggeredByUserName: map['triggeredByUserName'] as String? ?? 'Anonymous',
      notes: map['notes'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
