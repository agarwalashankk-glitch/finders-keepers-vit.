enum ClaimStatus {
  pending,
  under_review,
  verified,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case ClaimStatus.pending:
        return 'Pending Review';
      case ClaimStatus.under_review:
        return 'Under Review';
      case ClaimStatus.verified:
        return 'Verified';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ClaimStatus fromString(String val) {
    return ClaimStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ClaimStatus.pending,
    );
  }
}

class ClaimModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemCategory;
  final String itemReporterId; // The finder's user ID
  final String claimantId;
  final String claimantName;
  final String claimantEmail;
  final ClaimStatus status;

  // PRIVATE VERIFICATION PROOF (Never exposed on public listing)
  final String distinguishingFeatures;
  final String hiddenContents;
  final String serialOrIdentifier;
  final String lossCircumstance;
  final List<String> proofImageUrls;

  // Review & Handover
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;
  final String? handoverVerificationCode; // 6-digit secure code generated upon verification

  const ClaimModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemCategory,
    required this.itemReporterId,
    required this.claimantId,
    required this.claimantName,
    required this.claimantEmail,
    this.status = ClaimStatus.pending,
    required this.distinguishingFeatures,
    required this.hiddenContents,
    this.serialOrIdentifier = '',
    required this.lossCircumstance,
    this.proofImageUrls = const [],
    required this.createdAt,
    this.reviewedAt,
    this.reviewerNotes,
    this.handoverVerificationCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemCategory': itemCategory,
      'itemReporterId': itemReporterId,
      'claimantId': claimantId,
      'claimantName': claimantName,
      'claimantEmail': claimantEmail,
      'status': status.name,
      'distinguishingFeatures': distinguishingFeatures,
      'hiddenContents': hiddenContents,
      'serialOrIdentifier': serialOrIdentifier,
      'lossCircumstance': lossCircumstance,
      'proofImageUrls': proofImageUrls,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerNotes': reviewerNotes,
      'handoverVerificationCode': handoverVerificationCode,
    };
  }

  factory ClaimModel.fromMap(Map<String, dynamic> map, String id) {
    return ClaimModel(
      id: id,
      itemId: map['itemId'] as String? ?? '',
      itemTitle: map['itemTitle'] as String? ?? '',
      itemCategory: map['itemCategory'] as String? ?? '',
      itemReporterId: map['itemReporterId'] as String? ?? '',
      claimantId: map['claimantId'] as String? ?? '',
      claimantName: map['claimantName'] as String? ?? 'Anonymous Student',
      claimantEmail: map['claimantEmail'] as String? ?? '',
      status: ClaimStatus.fromString(map['status'] as String? ?? 'pending'),
      distinguishingFeatures: map['distinguishingFeatures'] as String? ?? '',
      hiddenContents: map['hiddenContents'] as String? ?? '',
      serialOrIdentifier: map['serialOrIdentifier'] as String? ?? '',
      lossCircumstance: map['lossCircumstance'] as String? ?? '',
      proofImageUrls: (map['proofImageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'].toString())
          : null,
      reviewerNotes: map['reviewerNotes'] as String?,
      handoverVerificationCode: map['handoverVerificationCode'] as String?,
    );
  }

  ClaimModel copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? itemCategory,
    String? itemReporterId,
    String? claimantId,
    String? claimantName,
    String? claimantEmail,
    ClaimStatus? status,
    String? distinguishingFeatures,
    String? hiddenContents,
    String? serialOrIdentifier,
    String? lossCircumstance,
    List<String>? proofImageUrls,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewerNotes,
    String? handoverVerificationCode,
  }) {
    return ClaimModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemCategory: itemCategory ?? this.itemCategory,
      itemReporterId: itemReporterId ?? this.itemReporterId,
      claimantId: claimantId ?? this.claimantId,
      claimantName: claimantName ?? this.claimantName,
      claimantEmail: claimantEmail ?? this.claimantEmail,
      status: status ?? this.status,
      distinguishingFeatures:
          distinguishingFeatures ?? this.distinguishingFeatures,
      hiddenContents: hiddenContents ?? this.hiddenContents,
      serialOrIdentifier: serialOrIdentifier ?? this.serialOrIdentifier,
      lossCircumstance: lossCircumstance ?? this.lossCircumstance,
      proofImageUrls: proofImageUrls ?? this.proofImageUrls,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      handoverVerificationCode:
          handoverVerificationCode ?? this.handoverVerificationCode,
    );
  }
}
