import 'package:flutter/material.dart';

import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:car_social_media_app/core/shared/widgets/tagging/tag_strip.dart';

/// Bottom composer of the thread page. Shows a "replying to @user" strip when
/// targeting a reply, the tags picked for the reply, and a button that opens
/// the tag sheet; replaced by [LockedBar] on locked threads.
class ReplyInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSubmitting;
  final String? replyingToUsername;
  final List<TaggedPerson> taggedPeople;
  final List<TaggedCar> taggedCars;
  final VoidCallback onSend;
  final VoidCallback onCancelTarget;
  final VoidCallback onOpenTags;
  final ValueChanged<String> onRemoveTaggedPerson;
  final ValueChanged<String> onRemoveTaggedCar;

  const ReplyInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSubmitting,
    this.replyingToUsername,
    this.taggedPeople = const [],
    this.taggedCars = const [],
    required this.onSend,
    required this.onCancelTarget,
    required this.onOpenTags,
    required this.onRemoveTaggedPerson,
    required this.onRemoveTaggedCar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingToUsername != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.forumsReplyingTo(replyingToUsername!),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.mute,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onCancelTarget,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
              TagStrip(
                people: taggedPeople,
                cars: taggedCars,
                onRemovePerson: onRemoveTaggedPerson,
                onRemoveCar: onRemoveTaggedCar,
              ),
              Row(
                children: [
                  _TagButton(
                    active: taggedPeople.isNotEmpty || taggedCars.isNotEmpty,
                    tooltip: l10n.forumsAddTagsTooltip,
                    onTap: onOpenTags,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 4,
                      cursorColor: AppColors.accent,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.forumsAddReply,
                        hintStyle: const TextStyle(
                          color: AppColors.muteSoft,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isSubmitting ? null : onSend,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the tag sheet; tinted while the reply carries tags.
class _TagButton extends StatelessWidget {
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _TagButton({
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.accentSoft : AppColors.bgSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 19,
            color: active ? AppColors.accent : AppColors.mute,
          ),
        ),
      ),
    );
  }
}

/// Replaces the composer when the thread is locked.
class LockedBar extends StatelessWidget {
  const LockedBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 15, color: AppColors.mute),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.forumsLockedBar,
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
