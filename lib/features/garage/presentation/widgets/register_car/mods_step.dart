import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'mod_slot.dart';
import 'register_car_fields.dart';

const _monthsShort = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// Step 2 — the optional build log. Lists each logged modification as a rich
/// card and offers an add affordance that opens the full-screen build-log
/// editor. Each row is a [ModSlot] — a new mod or an existing one being edited.
class ModsStep extends StatelessWidget {
  final List<ModSlot> mods;
  final List<CarModCategoryEntity> categories;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int>? onEdit;

  const ModsStep({
    super.key,
    required this.mods,
    required this.categories,
    required this.onAdd,
    required this.onRemove,
    this.onEdit,
  });

  String _categoryName(AppLocalizations l10n, String id) {
    for (final c in categories) {
      if (c.id == id) return c.modName;
    }
    return l10n.garageModFallbackCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(
          title: l10n.garageRegisterModsTitle,
          subtitle: l10n.garageRegisterModsSubtitle,
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < mods.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ModCard(
              mod: mods[i],
              category: _categoryName(l10n, mods[i].categoryId),
              onRemove: () => onRemove(i),
              onTap: onEdit == null ? null : () => onEdit!(i),
            ),
          ),
        _AddModButton(onTap: onAdd),
      ],
    );
  }
}

class _ModCard extends StatelessWidget {
  final ModSlot mod;
  final String category;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const _ModCard({
    required this.mod,
    required this.category,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${_monthsShort[mod.installationDate.month - 1]} ${mod.installationDate.year}';
    final priceText = mod.price != null
        ? '€${mod.price!.toStringAsFixed(mod.price! % 1 == 0 ? 0 : 2)}'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(kRegisterRadius),
          boxShadow: kRegisterSurfaceShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Thumb(filePath: mod.thumbFilePath, url: mod.thumbUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mod.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceText == null ? date : '$date · $priceText',
                    style: TextStyle(
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
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.mute,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? filePath;
  final String? url;
  const _Thumb({required this.filePath, this.url});

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = filePath != null
        ? FileImage(File(filePath!))
        : (url != null ? NetworkImage(url!) : null);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(kRegisterRadius),
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? Icon(Icons.build_rounded, color: AppColors.muteSoft, size: 24)
          : null,
    );
  }
}

class _AddModButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddModButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RegisterAddSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        // Left-aligned like every other control in the wizard — a centred
        // label here read as a different kind of widget than the mod cards
        // stacked above it.
        child: Align(
          alignment: Alignment.centerLeft,
          child: RegisterFitted(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.garageAddModification,
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
      ),
    );
  }
}
