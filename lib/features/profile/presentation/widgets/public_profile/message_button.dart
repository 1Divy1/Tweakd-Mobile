import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../messages/domain/entities/message_user.dart';
import '../../../../messages/presentation/bloc/unread/cubit.dart';
import '../../../domain/entities/profile.dart';

/// Secondary, outlined "message" action shown next to the follow CTA on a
/// user's public profile. Opens a private chat with them, pushing onto the
/// stack. Routes to `/messages/new` carrying the peer via `extra`: the chat
/// has no conversation id yet, and the first message adopts (and backfills)
/// any conversation that already exists server-side — see ChatBloc.
class MessageButton extends StatelessWidget {
  final ProfileEntity profile;

  const MessageButton({super.key, required this.profile});

  Future<void> _openChat(BuildContext context) async {
    final peer = MessageUserEntity(
      id: profile.id,
      username: profile.username,
      avatarUrl: profile.avatarUrl.isEmpty ? null : profile.avatarUrl,
      isVerified: profile.isVerified,
    );
    final dmUnread = context.read<DmUnreadCubit>();
    await context.push('/messages/new', extra: peer);
    // This path bypasses the inbox, so the feed pill's refresh-on-return never
    // fires — re-sync the badge here after the chat marked messages read.
    dmUnread.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.profileMessage,
      child: SizedBox(
        width: 52,
        height: 50,
        child: OutlinedButton(
          onPressed: () => _openChat(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            padding: EdgeInsets.zero,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Icon(
            Icons.mode_comment_outlined,
            color: AppColors.ink,
            size: 20,
          ),
        ),
      ),
    );
  }
}
