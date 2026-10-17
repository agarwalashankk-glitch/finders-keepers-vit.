import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/campus_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/input_validators.dart';
import '../../../models/item_status.dart';
import '../../../providers/report_form_providers.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class ReportItemScreen extends ConsumerStatefulWidget {
  final ItemReportType initialType;

  const ReportItemScreen({
    super.key,
    this.initialType = ItemReportType.lost,
  });

  @override
  ConsumerState<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends ConsumerState<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _areaDetailController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(reportFormProvider);
    _titleController = TextEditingController(text: formState.title);
    _descController = TextEditingController(text: formState.description);
    _areaDetailController = TextEditingController(text: formState.areaDetail);

    // Set initial report type if not restored from existing draft
    if (!formState.hasRestoredDraft) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reportFormProvider.notifier).setReportType(widget.initialType);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _areaDetailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final storageService = ref.read(storageServiceProvider);
    final file = await storageService.pickImage(source: source);
    if (file != null) {
      ref.read(reportFormProvider.notifier).addImage(file);
    }
  }

  Future<void> _selectDate() async {
    final formState = ref.read(reportFormProvider);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: formState.incidentDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(formState.incidentDateTime),
      );

      final combined = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 12,
        pickedTime?.minute ?? 0,
      );

      ref.read(reportFormProvider.notifier).setIncidentDateTime(combined);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(reportFormProvider.notifier);
    final createdItem = await formNotifier.submitReport();

    if (createdItem != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${createdItem.reportType.displayName} published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(reportFormProvider);
    final formNotifier = ref.read(reportFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formState.reportType == ItemReportType.lost
              ? 'Report Lost Item'
              : 'Report Found Item',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Discard Draft',
            onPressed: () async {
              final discard = await ConfirmationDialog.show(
                context: context,
                title: 'Discard Draft?',
                message: 'Are you sure you want to discard your draft report?',
                confirmText: 'Discard',
                isDestructive: true,
              );
              if (discard == true) {
                await formNotifier.discardDraft();
                _titleController.clear();
                _descController.clear();
                _areaDetailController.clear();
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Restored draft notice
              if (formState.hasRestoredDraft)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.restore, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unfinished draft restored from local storage.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Report Type Selector (Lost vs Found)
              Row(
                children: [
                  Expanded(
                    child: _buildTypeSelector(
                      title: 'Lost Item',
                      icon: Icons.search,
                      isSelected: formState.reportType == ItemReportType.lost,
                      activeColor: AppColors.lostColor,
                      onTap: () => formNotifier.setReportType(ItemReportType.lost),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeSelector(
                      title: 'Found Item',
                      icon: Icons.inventory_2_outlined,
                      isSelected: formState.reportType == ItemReportType.found,
                      activeColor: AppColors.foundColor,
                      onTap: () => formNotifier.setReportType(ItemReportType.found),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              const Text(
                'Item Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: formState.category.isNotEmpty ? formState.category : null,
                hint: const Text('Select category (e.g. ID Cards, Electronics)'),
                items: AppConstants.categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) formNotifier.setCategory(val);
                },
                validator: InputValidators.validateCategory,
              ),
              const SizedBox(height: 16),

              // Item Title
              CustomTextField(
                controller: _titleController,
                label: 'Item Name / Title',
                hint: 'e.g. Casio fx-991EX Scientific Calculator',
                validator: InputValidators.validateItemTitle,
                onChanged: (val) => formNotifier.setTitle(val),
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Provide distinctive details, brand, color, case condition, etc.',
                maxLines: 4,
                validator: InputValidators.validateItemDescription,
                onChanged: (val) => formNotifier.setDescription(val),
              ),
              const SizedBox(height: 20),

              // Approximate Location (Campus Zone)
              const Text(
                'Approximate Campus Zone',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the general campus building or plaza. Exact private locations are never displayed.',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: formState.zoneId,
                items: CampusLocations.zones.map((zone) {
                  return DropdownMenuItem(
                    value: zone.id,
                    child: Text('${zone.name} (${zone.shortCode})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) formNotifier.setZone(val);
                },
              ),
              const SizedBox(height: 12),

              // Area Detail / Floor Hint
              CustomTextField(
                controller: _areaDetailController,
                label: 'Floor / Area Details (Optional)',
                hint: 'e.g. 3rd Floor Computer Lab 312 or Gazebo Seating',
                onChanged: (val) => formNotifier.setAreaDetail(val),
              ),
              const SizedBox(height: 16),

              // Incident Date & Time
              const Text(
                'Date & Time',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormatter.formatFull(formState.incidentDateTime),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image Attachments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attach Photographs (Max 3)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${formState.localImages.length} / 3',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildImagePickerRow(formState, formNotifier),

              const SizedBox(height: 24),

              // Upload / Submission Progress Bar
              if (formState.isSubmitting) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uploading & publishing to campus board...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${(formState.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: formState.uploadProgress,
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],

              // Error display
              if (formState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lostBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    formState.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              CustomButton(
                text: 'Publish Report to Campus Board',
                isLoading: formState.isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerRow(ReportFormState state, ReportFormNotifier notifier) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Photo Button
          if (state.localImages.length < 3)
            InkWell(
              onTap: () => _showImageSourceDialog(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 24),
                    SizedBox(height: 4),
                    Text(
                      'Add Photo',
                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          // Thumbnails of chosen images
          ...state.localImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(left: 10),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => notifier.removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo with Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Select from Photo Library'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
