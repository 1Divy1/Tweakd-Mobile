import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/reference_data.dart';
import '../../bloc/add_car/event.dart';
import 'register_car_fields.dart';

const _monthsShort = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// Step 6 — the optional build log. Lists each logged modification as a rich
/// card and offers an add affordance that opens the build-item sheet.
class ModsStep extends StatelessWidget {
  final List<NewModInput> mods;
  final List<CarModCategoryEntity> categories;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ModsStep({
    super.key,
    required this.mods,
    required this.categories,
    required this.onAdd,
    required this.onRemove,
  });

  String _categoryName(String id) {
    for (final c in categories) {
      if (c.id == id) return c.modName;
    }
    return 'MODIFICATION';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionHeader(
          label: '06 — MODS',
          title: 'Build log',
          subtitle: 'Optional — log the work that makes it yours.',
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < mods.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ModCard(
              mod: mods[i],
              category: _categoryName(mods[i].request.categoryId),
              onRemove: () => onRemove(i),
            ),
          ),
        _AddModButton(onTap: onAdd),
      ],
    );
  }
}

class _ModCard extends StatelessWidget {
  final NewModInput mod;
  final String category;
  final VoidCallback onRemove;

  const _ModCard({
    required this.mod,
    required this.category,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final req = mod.request;
    final thumb = (mod.after ?? mod.before)?.path;
    final date =
        '${_monthsShort[req.installationDate.month - 1]} ${req.installationDate.year}';
    final priceText = req.price != null
        ? '€${req.price!.toStringAsFixed(req.price! % 1 == 0 ? 0 : 2)}'
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Thumb(filePath: thumb),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  req.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  priceText == null ? date : '$date · $priceText',
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.mute, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? filePath;
  const _Thumb({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        image: filePath != null
            ? DecorationImage(image: FileImage(File(filePath!)), fit: BoxFit.cover)
            : null,
      ),
      child: filePath == null
          ? const Icon(Icons.build_rounded, color: AppColors.muteSoft, size: 24)
          : null,
    );
  }
}

class _AddModButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddModButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const DashedRoundedBorder(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'ADD MODIFICATION',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
