import 'package:flutter/material.dart';

import 'package:tweakd/features/garage/domain/entities/reference_data.dart';

import '../../../../../l10n/app_localizations.dart';
import '../shared/forum_section_label.dart';
import 'forum_brand_card.dart';
import '../../../../../core/shared/layout/app_layout.dart';

/// The browse page's brand catalog: every brand that has a forum hub.
class ForumBrandGrid extends StatelessWidget {
  final List<CarBrandEntity> brands;
  final ValueChanged<CarBrandEntity> onOpen;

  const ForumBrandGrid({super.key, required this.brands, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24) + AppLayout.inset(context),
      children: [
        ForumSectionLabel(label: l10n.forumsBrandsCount(brands.length)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final brand = brands[index];
            return ForumBrandCard(
              brand: brand,
              threadCount: brand.threadCount,
              onTap: () => onOpen(brand),
            );
          },
        ),
      ],
    );
  }
}
