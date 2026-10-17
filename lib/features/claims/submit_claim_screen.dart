import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/input_validators.dart';
import '../../../models/item_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/claim_providers.dart';
import '../../../providers/report_form_providers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class SubmitClaimScreen extends ConsumerStatefulWidget {
  final ItemModel item;

  const SubmitClaimScreen({super.key, required this.item});

  @override
  ConsumerState<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends ConsumerState<SubmitClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _featuresController = TextEditingController();
  final _contentsController = TextEditingController();
  final _serialController = TextEditingController();
  final _circumstanceController = TextEditingController();

  final List<File> _proofImages = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _featuresController.dispose();
    _contentsController.dispose();
    _serialController.dispose();
    _circumstanceController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage() async {
    if (_proofImages.length >= 2) return;
    final storageService = ref.read(storageServiceProvider);
    final file = await storageService.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _proofImages.add(file);
      });
    }
  }

  Future<void> _handleSubmitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      setState(() => _errorMessage = 'Please sign in to submit a claim');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      final List<String> proofUrls = [];

      for (final img in _proofImages) {
        final url = await storage.uploadClaimProofImage(
          file: img,
          claimId: widget.item.id,
        );
        proofUrls.add(url);
      }

      final claimRepo = ref.read(claimRepositoryProvider);
      await claimRepo.submitClaim(
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        itemCategory: widget.item.category,
        itemReporterId: widget.item.reporterId,
        claimantId: currentUser.uid,
        claimantName: currentUser.displayName,
        claimantEmail: currentUser.email,
        distinguishingFeatures: _featuresController.text.trim(),
        hiddenContents: _contentsController.text.trim(),
        serialOrIdentifier: _serialController.text.trim(),
        lossCircumstance: _circumstanceController.text.trim(),
        proofImageUrls: proofUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ownership claim submitted! The finder has been notified to review your proof.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Ownership'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security / Privacy Warning Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Private Ownership Verification',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To prevent fraudulent claims, your answers below are kept strictly private and will only be shared with the finder for verification before handover.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Target Item Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claiming Item: ${widget.item.title}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Found at ${widget.item.approximateLocation.zoneName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lostBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Distinguishing Features
              CustomTextField(
                controller: _featuresController,
                label: 'Distinguishing Features & Marks',
                hint:
                    'e.g. Scratches on left corner, specific cartoon sticker, small tear, keychain attachment',
                maxLines: 3,
                validator: InputValidators.validateClaimEvidence,
              ),
              const SizedBox(height: 16),

              // 2. Hidden Contents
              CustomTextField(
                controller: _contentsController,
                label: 'Hidden Contents / Internal Details',
                hint:
                    'e.g. What cards are inside the wallet? What is the phone wallpaper or lock hint? What notes are in the bag?',
                maxLines: 3,
                validator: InputValidators.validateClaimEvidence,
              ),
              const SizedBox(height: 16),

              // 3. Serial Number / ID (Optional)
              CustomTextField(
                controller: _serialController,
                label: 'Serial Number / ID Number (If applicable)',
                hint: 'e.g. Last 4 digits of bank card, model number, device serial',
              ),
              const SizedBox(height: 16),

              // 4. Circumstance of Loss
              CustomTextField(
                controller: _circumstanceController,
                label: 'Where and when do you believe you lost it?',
                hint:
                    'e.g. Attended 10 AM class in TT 3rd floor, sat in 2nd row near window, noticed missing at foodys',
                maxLines: 2,
                validator: (v) => (v == null || v.trim().length < 15)
                    ? 'Please provide approximate loss circumstance (min 15 chars)'
                    : null,
              ),
              const SizedBox(height: 20),

              // Proof Image Attachments (Receipt, old photo of item)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Optional Proof of Ownership (Receipt/Old Photo)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_proofImages.length} / 2',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_proofImages.length < 2)
                    InkWell(
                      onTap: _pickProofImage,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                            SizedBox(height: 4),
                            Text('Add Proof', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ..._proofImages.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            setState(() => _proofImages.removeAt(idx));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Submit Private Claim for Review',
                isLoading: _isSubmitting,
                onPressed: _handleSubmitClaim,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
