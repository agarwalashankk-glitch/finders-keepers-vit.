class ApproximateLocationModel {
  final String zoneId;
  final String zoneName;
  final double approxLatitude;
  final double approxLongitude;
  final double approxRadiusMeters;
  final String areaDetail;

  const ApproximateLocationModel({
    required this.zoneId,
    required this.zoneName,
    required this.approxLatitude,
    required this.approxLongitude,
    this.approxRadiusMeters = 65.0,
    this.areaDetail = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'zoneId': zoneId,
      'zoneName': zoneName,
      'approxLatitude': approxLatitude,
      'approxLongitude': approxLongitude,
      'approxRadiusMeters': approxRadiusMeters,
      'areaDetail': areaDetail,
    };
  }

  factory ApproximateLocationModel.fromMap(Map<String, dynamic> map) {
    return ApproximateLocationModel(
      zoneId: map['zoneId'] as String? ?? 'tt',
      zoneName: map['zoneName'] as String? ?? 'Technology Tower (TT)',
      approxLatitude: (map['approxLatitude'] as num?)?.toDouble() ?? 12.9708,
      approxLongitude: (map['approxLongitude'] as num?)?.toDouble() ?? 79.1594,
      approxRadiusMeters: (map['approxRadiusMeters'] as num?)?.toDouble() ?? 65.0,
      areaDetail: map['areaDetail'] as String? ?? '',
    );
  }

  ApproximateLocationModel copyWith({
    String? zoneId,
    String? zoneName,
    double? approxLatitude,
    double? approxLongitude,
    double? approxRadiusMeters,
    String? areaDetail,
  }) {
    return ApproximateLocationModel(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      approxLatitude: approxLatitude ?? this.approxLatitude,
      approxLongitude: approxLongitude ?? this.approxLongitude,
      approxRadiusMeters: approxRadiusMeters ?? this.approxRadiusMeters,
      areaDetail: areaDetail ?? this.areaDetail,
    );
  }
}
