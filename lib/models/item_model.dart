import 'approximate_location_model.dart';
import 'item_status.dart';

class ItemModel {
  final String id;
  final ItemReportType reportType;
  final ItemStatus status;
  final String title;
  final String category;
  final String description;
  final List<String> imageUrls;
  final ApproximateLocationModel approximateLocation;
  final DateTime incidentDateTime;
  final String reporterId;
  final String reporterName;
  final int activeClaimCount;
  final String? verifiedClaimId;
  final bool isFlagged;
  final String? flagReason;
  final String submissionId; // For client idempotency
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemModel({
    required this.id,
    required this.reportType,
    required this.status,
    required this.title,
    required this.category,
    required this.description,
    this.imageUrls = const [],
    required this.approximateLocation,
    required this.incidentDateTime,
    required this.reporterId,
    required this.reporterName,
    this.activeClaimCount = 0,
    this.verifiedClaimId,
    this.isFlagged = false,
    this.flagReason,
    required this.submissionId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLost => reportType == ItemReportType.lost;
  bool get isFound => reportType == ItemReportType.found;
  bool get canBeClaimed => isFound && (status == ItemStatus.found || status == ItemStatus.claimed);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportType': reportType.name,
      'status': status.name,
      'title': title,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'approximateLocation': approximateLocation.toMap(),
      'incidentDateTime': incidentDateTime.toIso8601String(),
      'reporterId': reporterId,
      'reporterName': reporterName,
      'activeClaimCount': activeClaimCount,
      'verifiedClaimId': verifiedClaimId,
      'isFlagged': isFlagged,
      'flagReason': flagReason,
      'submissionId': submissionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
      id: id,
      reportType: ItemReportType.fromString(map['reportType'] as String? ?? 'lost'),
      status: ItemStatus.fromString(map['status'] as String? ?? 'lost'),
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      approximateLocation: map['approximateLocation'] != null
          ? ApproximateLocationModel.fromMap(
              Map<String, dynamic>.from(map['approximateLocation'] as Map))
          : const ApproximateLocationModel(
              zoneId: 'tt',
              zoneName: 'Technology Tower (TT)',
              approxLatitude: 12.9708,
              approxLongitude: 79.1594,
            ),
      incidentDateTime: map['incidentDateTime'] != null
          ? DateTime.tryParse(map['incidentDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? 'Campus User',
      activeClaimCount: (map['activeClaimCount'] as num?)?.toInt() ?? 0,
      verifiedClaimId: map['verifiedClaimId'] as String?,
      isFlagged: map['isFlagged'] as bool? ?? false,
      flagReason: map['flagReason'] as String?,
      submissionId: map['submissionId'] as String? ?? id,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ItemModel copyWith({
    String? id,
    ItemReportType? reportType,
    ItemStatus? status,
    String? title,
    String? category,
    String? description,
    List<String>? imageUrls,
    ApproximateLocationModel? approximateLocation,
    DateTime? incidentDateTime,
    String? reporterId,
    String? reporterName,
    int? activeClaimCount,
    String? verifiedClaimId,
    bool? isFlagged,
    String? flagReason,
    String? submissionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      status: status ?? this.status,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      incidentDateTime: incidentDateTime ?? this.incidentDateTime,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      activeClaimCount: activeClaimCount ?? this.activeClaimCount,
      verifiedClaimId: verifiedClaimId ?? this.verifiedClaimId,
      isFlagged: isFlagged ?? this.isFlagged,
      flagReason: flagReason ?? this.flagReason,
      submissionId: submissionId ?? this.submissionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
