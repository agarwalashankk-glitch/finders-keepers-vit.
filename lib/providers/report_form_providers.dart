import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/campus_locations.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/fuzzy_location.dart';
import '../models/approximate_location_model.dart';
import '../models/item_model.dart';
import '../models/item_status.dart';
import '../repositories/draft_repository.dart';
import '../services/storage_service.dart';
import 'auth_providers.dart';
import 'item_providers.dart';

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class ReportFormState {
  final ItemReportType reportType;
  final String title;
  final String category;
  final String description;
  final String zoneId;
  final String areaDetail;
  final DateTime incidentDateTime;
  final List<File> localImages;
  final List<String> uploadedUrls;
  final bool isSubmitting;
  final double uploadProgress;
  final String? errorMessage;
  final bool isSuccess;
  final bool hasRestoredDraft;
  final String submissionId;

  const ReportFormState({
    this.reportType = ItemReportType.lost,
    this.title = '',
    this.category = '',
    this.description = '',
    this.zoneId = 'tt',
    this.areaDetail = '',
    required this.incidentDateTime,
    this.localImages = const [],
    this.uploadedUrls = const [],
    this.isSubmitting = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.isSuccess = false,
    this.hasRestoredDraft = false,
    required this.submissionId,
  });

  ReportFormState copyWith({
    ItemReportType? reportType,
    String? title,
    String? category,
    String? description,
    String? zoneId,
    String? areaDetail,
    DateTime? incidentDateTime,
    List<File>? localImages,
    List<String>? uploadedUrls,
    bool? isSubmitting,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    bool? hasRestoredDraft,
    String? submissionId,
  }) {
    return ReportFormState(
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      zoneId: zoneId ?? this.zoneId,
      areaDetail: areaDetail ?? this.areaDetail,
      incidentDateTime: incidentDateTime ?? this.incidentDateTime,
      localImages: localImages ?? this.localImages,
      uploadedUrls: uploadedUrls ?? this.uploadedUrls,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      hasRestoredDraft: hasRestoredDraft ?? this.hasRestoredDraft,
      submissionId: submissionId ?? this.submissionId,
    );
  }
}

class ReportFormNotifier extends StateNotifier<ReportFormState> {
  final Ref _ref;

  ReportFormNotifier(this._ref)
      : super(
          ReportFormState(
            incidentDateTime: DateTime.now(),
            submissionId: const Uuid().v4(),
          ),
        ) {
    checkAndLoadDraft();
  }

  void setReportType(ItemReportType type) {
    state = state.copyWith(reportType: type);
    _autoSaveDraft();
  }

  void setTitle(String val) {
    state = state.copyWith(title: val);
    _autoSaveDraft();
  }

  void setCategory(String val) {
    state = state.copyWith(category: val);
    _autoSaveDraft();
  }

  void setDescription(String val) {
    state = state.copyWith(description: val);
    _autoSaveDraft();
  }

  void setZone(String zoneId) {
    state = state.copyWith(zoneId: zoneId);
    _autoSaveDraft();
  }

  void setAreaDetail(String val) {
    state = state.copyWith(areaDetail: val);
    _autoSaveDraft();
  }

  void setIncidentDateTime(DateTime val) {
    state = state.copyWith(incidentDateTime: val);
    _autoSaveDraft();
  }

  void addImage(File file) {
    if (state.localImages.length < 3) {
      state = state.copyWith(localImages: [...state.localImages, file]);
      _autoSaveDraft();
    }
  }

  void removeImage(int index) {
    final updated = List<File>.from(state.localImages)..removeAt(index);
    state = state.copyWith(localImages: updated);
    _autoSaveDraft();
  }

  Future<void> checkAndLoadDraft() async {
    final draftRepo = _ref.read(draftRepositoryProvider);
    final draft = await draftRepo.loadDraft();
    if (draft != null) {
      final existingFiles = draft.localImagePaths
          .map((p) => File(p))
          .where((f) => f.existsSync())
          .toList();

      state = state.copyWith(
        reportType: ItemReportType.fromString(draft.reportType),
        title: draft.title,
        category: draft.category,
        description: draft.description,
        zoneId: draft.zoneId,
        areaDetail: draft.areaDetail,
        incidentDateTime: draft.incidentDateTime,
        localImages: existingFiles,
        hasRestoredDraft: true,
      );
    }
  }

  void _autoSaveDraft() {
    final draftRepo = _ref.read(draftRepositoryProvider);
    final draft = DraftReportData(
      reportType: state.reportType.name,
      title: state.title,
      category: state.category,
      description: state.description,
      zoneId: state.zoneId,
      areaDetail: state.areaDetail,
      incidentDateTime: state.incidentDateTime,
      localImagePaths: state.localImages.map((f) => f.path).toList(),
    );
    draftRepo.saveDraft(draft);
  }

  Future<void> discardDraft() async {
    final draftRepo = _ref.read(draftRepositoryProvider);
    await draftRepo.clearDraft();
    state = ReportFormState(
      incidentDateTime: DateTime.now(),
      submissionId: const Uuid().v4(),
    );
  }

  Future<ItemModel?> submitReport() async {
    // Prevent duplicate multi-tap submission
    if (state.isSubmitting) return null;

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = state.copyWith(errorMessage: 'Please log in to submit a report');
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true, uploadProgress: 0.05);

    try {
      final storage = _ref.read(storageServiceProvider);
      final itemRepo = _ref.read(itemRepositoryProvider);

      // 1. Upload attached images with progress tracking
      final List<String> imageUrls = [];
      if (state.localImages.isNotEmpty) {
        for (int i = 0; i < state.localImages.length; i++) {
          final file = state.localImages[i];
          final url = await storage.uploadItemImage(
            file: file,
            itemId: state.submissionId,
            onProgress: (prog) {
              final totalProgress = 0.05 + ((i + prog) / state.localImages.length) * 0.65;
              state = state.copyWith(uploadProgress: totalProgress);
            },
          );
          imageUrls.add(url);
        }
      }

      state = state.copyWith(uploadProgress: 0.75);

      // 2. Resolve campus zone and calculate approximate privacy coordinates
      final campusZone = CampusLocations.getById(state.zoneId);
      final privacyCoords = FuzzyLocation.applyPrivacyOffset(
        latitude: campusZone.latitude,
        longitude: campusZone.longitude,
        approxRadiusMeters: 65.0,
      );

      final approximateLocation = ApproximateLocationModel(
        zoneId: campusZone.id,
        zoneName: campusZone.name,
        approxLatitude: privacyCoords.lat,
        approxLongitude: privacyCoords.lng,
        approxRadiusMeters: 65.0,
        areaDetail: state.areaDetail.trim(),
      );

      state = state.copyWith(uploadProgress: 0.90);

      // 3. Create Item Report in Firestore with Idempotency ID
      final createdItem = await itemRepo.createItem(
        reportType: state.reportType,
        title: state.title.trim(),
        category: state.category,
        description: state.description.trim(),
        imageUrls: imageUrls,
        approximateLocation: approximateLocation,
        incidentDateTime: state.incidentDateTime,
        reporterId: currentUser.uid,
        reporterName: currentUser.displayName,
        submissionId: state.submissionId,
      );

      // 4. Clear local draft on success
      await _ref.read(draftRepositoryProvider).clearDraft();

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        uploadProgress: 1.0,
      );

      return createdItem;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e is AppException ? e.message : 'Submission failed: $e',
      );
      return null;
    }
  }
}

final reportFormProvider =
    StateNotifierProvider<ReportFormNotifier, ReportFormState>((ref) {
  return ReportFormNotifier(ref);
});
