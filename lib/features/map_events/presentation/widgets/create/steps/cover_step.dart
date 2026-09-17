import 'dart:io';

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../bloc/create_event/state.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// Step 6 — the cover image. Gallery picking is unchanged; only the framing is.
class CoverStep extends StatelessWidget {
  final CreateMapEventState state;
  final VoidCallback onPick;

  const CoverStep({super.key, required this.state, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final picked = state.cover;
    final existing = state.existingCoverUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepCoverTitle,
          subtitle: l10n.mapEventsStepCoverSubtitle,
        ),
        if (picked == null && existing == null)
          EventDashedButton(
            label: l10n.mapEventsCoverAdd,
            icon: Icons.photo_camera_outlined,
            height: 190,
            onTap: onPick,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 26,
                  color: AppColors.mute,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.mapEventsCoverAdd,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mute,
                  ),
                ),
              ],
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(kCreateEventRadius),
            child: Stack(
              children: [
                // The 16:9 the cover is cropped to everywhere it's shown, so
                // what the organizer approves here is what lands on the map.
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SizedBox(
                    width: double.infinity,
                    child: picked != null
                        ? Image.file(File(picked.path), fit: BoxFit.cover)
                        : Image.network(existing!, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onPick,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          l10n.mapEventsCoverChange,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
