import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Step 1 — visual identity and the car's basic make/model/year details.
class IdentityStep extends StatelessWidget {
  final String? coverFilePath;
  final CarBrandEntity? selectedBrand;
  final CarModelEntity? selectedModel;
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final bool modelsLoading;
  final TextEditingController yearCtrl;
  final TextEditingController chassisCodeCtrl;
  final VoidCallback onPickCover;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final ValueChanged<CarModelEntity> onSelectModel;

  const IdentityStep({
    super.key,
    required this.coverFilePath,
    required this.selectedBrand,
    required this.selectedModel,
    required this.brands,
    required this.models,
    required this.modelsLoading,
    required this.yearCtrl,
    required this.chassisCodeCtrl,
    required this.onPickCover,
    required this.onSelectBrand,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionHeader(
          label: '01 — IDENTITY',
          title: 'Visual & basics',
        ),
        const SizedBox(height: 20),
        const RegisterFieldLabel('PRIMARY ASSET'),
        const SizedBox(height: 8),
        _PrimaryAssetCard(filePath: coverFilePath, onTap: onPickCover),
        const SizedBox(height: 20),
        const RegisterFieldLabel('MAKE'),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: 'e.g. Porsche',
          value: selectedBrand?.name,
          onTap: () => showRegisterPicker<CarBrandEntity>(
            context: context,
            title: 'Select Make',
            items: brands,
            labelOf: (b) => b.name,
            onSelected: onSelectBrand,
            searchable: true,
          ),
        ),
        const SizedBox(height: 16),
        const RegisterFieldLabel('MODEL'),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: selectedBrand == null
              ? 'Select a make first'
              : 'e.g. 911 GT3 RS',
          value: selectedModel?.model,
          loading: modelsLoading,
          enabled: selectedBrand != null,
          onTap: selectedBrand == null || modelsLoading
              ? null
              : () => showRegisterPicker<CarModelEntity>(
                    context: context,
                    title: 'Select Model',
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
                label: 'YEAR',
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
                  const RegisterFieldLabel('CHASSIS CODE'),
                  const SizedBox(height: 8),
                  RegisterFormField(
                    controller: chassisCodeCtrl,
                    hint: 'e.g. G82',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                ],
              ),
            ),
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
  final VoidCallback onTap;

  const _PrimaryAssetCard({required this.filePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = filePath != null;
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
                    image: FileImage(File(filePath!)),
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
              ? _filledOverlay()
              : _emptyPrompt(),
        ),
      ),
    );
  }

  Widget _filledOverlay() {
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
            child: const Text(
              'PRIMARY · 1 / 1',
              style: TextStyle(
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
        const Positioned(
          left: 16,
          bottom: 14,
          child: Text(
            'Studio shot · tap to replace',
            style: TextStyle(
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

  Widget _emptyPrompt() {
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
          const Text(
            'Add the studio shot',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to pick from your gallery',
            style: TextStyle(color: AppColors.mute, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
