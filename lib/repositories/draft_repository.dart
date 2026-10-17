import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class DraftReportData {
  final String reportType;
  final String title;
  final String category;
  final String description;
  final String zoneId;
  final String areaDetail;
  final DateTime incidentDateTime;
  final List<String> localImagePaths;

  const DraftReportData({
    required this.reportType,
    required this.title,
    required this.category,
    required this.description,
    required this.zoneId,
    required this.areaDetail,
    required this.incidentDateTime,
    required this.localImagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportType': reportType,
      'title': title,
      'category': category,
      'description': description,
      'zoneId': zoneId,
      'areaDetail': areaDetail,
      'incidentDateTime': incidentDateTime.toIso8601String(),
      'localImagePaths': localImagePaths,
    };
  }

  factory DraftReportData.fromMap(Map<String, dynamic> map) {
    return DraftReportData(
      reportType: map['reportType'] as String? ?? 'lost',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      zoneId: map['zoneId'] as String? ?? 'tt',
      areaDetail: map['areaDetail'] as String? ?? '',
      incidentDateTime: map['incidentDateTime'] != null
          ? DateTime.tryParse(map['incidentDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      localImagePaths: (map['localImagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DraftRepository {
  Future<void> saveDraft(DraftReportData draft) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(draft.toMap());
    await prefs.setString(AppConstants.reportDraftKey, jsonStr);
  }

  Future<DraftReportData?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(AppConstants.reportDraftKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DraftReportData.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.reportDraftKey);
  }
}
