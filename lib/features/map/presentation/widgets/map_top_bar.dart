import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The bar across the top of the map: a search field and the orange **+**.
///
/// The search field is **presentational only** — an owner decision, not an
/// oversight. It is rendered as a static row rather than a disabled
/// [TextField] on purpose: a focusable field that eats keystrokes and returns
/// nothing reads as a broken search, whereas a plain label reads as a place
/// where search will go. There is no `onTap` for the same reason.
///
/// The **+** opens the create-event flow, which is the map's only entry point
/// to it.
class MapTopBar extends StatelessWidget {
  const MapTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowAlpha(0x14),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.muteSoft,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    l10n.mapSearchPlaceholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.muteSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: l10n.mapCreateEvent,
          child: Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => context.push('/map-events/create'),
              borderRadius: BorderRadius.circular(15),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add_rounded, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
