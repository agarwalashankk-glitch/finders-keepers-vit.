enum NotificationType {
  claimSubmitted,
  claimVerified,
  claimRejected,
  potentialMatch,
  itemReturned,
  adminAlert;

  static NotificationType fromString(String val) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationType.claimSubmitted,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedItemId;
  final String? relatedClaimId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedItemId,
    this.relatedClaimId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'relatedItemId': relatedItemId,
      'relatedClaimId': relatedClaimId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String? ?? 'claimSubmitted'),
      relatedItemId: map['relatedItemId'] as String?,
      relatedClaimId: map['relatedClaimId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? relatedItemId,
    String? relatedClaimId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      relatedClaimId: relatedClaimId ?? this.relatedClaimId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
