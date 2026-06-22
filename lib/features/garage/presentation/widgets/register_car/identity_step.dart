import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Step 1 — visual identity and the car's basic make/model/year details.
class IdentityStep extends StatelessWidget {
  final String? coverFilePath;

  /// In edit mode, the URL of the existing cover. Shown when no new local file
  /// has been picked. A newly picked [coverFilePath] takes precedence.
  final String? coverNetworkUrl;
  final CarBrandEntity? selectedBrand;
  final CarModelEntity? selectedModel;
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final bool modelsLoading;
  final TextEditingController yearCtrl;
  final TextEditingController chassisCodeCtrl;
  final TextEditingController modelCodeCtrl;
  final VoidCallback onPickCover;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final ValueChanged<CarModelEntity> onSelectModel;

  const IdentityStep({
    super.key,
    required this.coverFilePath,
    this.coverNetworkUrl,
    required this.selectedBrand,
    required this.selectedModel,
    required this.brands,
    required this.models,
    required this.modelsLoading,
    required this.yearCtrl,
    required this.chassisCodeCtrl,
    required this.modelCodeCtrl,
    required this.onPickCover,
    required this.onSelectBrand,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(
          label: l10n.garageRegisterIdentityLabel,
          title: l10n.garageRegisterIdentityTitle,
        ),
        const SizedBox(height: 20),
        RegisterFieldLabel(l10n.garageFieldPrimaryAsset),
        const SizedBox(height: 8),
        _PrimaryAssetCard(
          filePath: coverFilePath,
          networkUrl: coverNetworkUrl,
          onTap: onPickCover,
        ),
        const SizedBox(height: 20),
        RegisterFieldLabel(l10n.garageFieldMake),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintMake,
          value: selectedBrand?.name,
          onTap: () => showRegisterPicker<CarBrandEntity>(
            context: context,
            title: l10n.garagePickerMake,
            items: brands,
            labelOf: (b) => b.name,
            onSelected: onSelectBrand,
            searchable: true,
          ),
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldModel),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: selectedBrand == null
              ? l10n.garageHintModelPickMakeFirst
              : l10n.garageHintModel,
          value: selectedModel?.model,
          loading: modelsLoading,
          enabled: selectedBrand != null,
          onTap: selectedBrand == null || modelsLoading
              ? null
              : () => showRegisterPicker<CarModelEntity>(
                    context: context,
                    title: l10n.garagePickerModel,
                    items: models,
                    labelOf: (m) => m.model,
                    onSelected: onSelectModel,
                    searchable: true,
                  ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldYear,
                controller: yearCtrl,
                hint: '2024',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegisterFieldLabel(l10n.garageFieldChassisCode,
                      optional: true),
                  const SizedBox(height: 8),
                  RegisterFormField(
                    controller: chassisCodeCtrl,
                    hint: '',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldModelCode, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
          controller: modelCodeCtrl,
          hint: l10n.garageHintModelCode,
          inputFormatters: [
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
    );
  }
}

/// The hero image card at the top of the identity step. Doubles as the picker
/// affordance whether or not a photo has been chosen yet.
class _PrimaryAssetCard extends StatelessWidget {
  final String? filePath;
  final String? networkUrl;
  final VoidCallback onTap;

  const _PrimaryAssetCard({
    required this.filePath,
    this.networkUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A freshly picked local file always wins over an existing remote cover.
    final ImageProvider? image = filePath != null
        ? FileImage(File(filePath!))
        : (networkUrl != null ? NetworkImage(networkUrl!) : null);
    final hasImage = image != null;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
            image: hasImage
                ? DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(hasImage ? 28 : 8),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: hasImage
              ? _filledOverlay(context)
              : _emptyPrompt(context),
        ),
      ),
    );
  }

  Widget _filledOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context)!.garagePrimaryAssetBadge,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.photo_camera_rounded,
                color: AppColors.ink, size: 20),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 14,
          child: Text(
            AppLocalizations.of(context)!.garageStudioShotReplace,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add_a_photo_rounded,
                color: AppColors.accent, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.garageAddStudioShot,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.garagePickFromGallery,
            style: const TextStyle(color: AppColors.mute, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
