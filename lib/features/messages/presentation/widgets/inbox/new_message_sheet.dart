import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message_user.dart';
import '../../bloc/compose/bloc.dart';
import '../../bloc/compose/event.dart';
import '../../bloc/compose/state.dart';
import '../shared/message_avatar.dart';
import '../shared/verified_badge.dart';
import '../../../../../core/shared/layout/app_layout.dart';

/// Opens the "New message" sheet. Resolves with the picked user, or null if
/// dismissed — the caller decides which chat route to open (there is no
/// create-conversation call; the first message creates it).
Future<MessageUserEntity?> showNewMessageSheet(BuildContext context) {
  return showModalBottomSheet<MessageUserEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<ComposeBloc>(
      create: (_) => getIt<ComposeBloc>()..add(const ComposeQueryChanged('')),
      child: const _NewMessageSheet(),
    ),
  );
}

class _NewMessageSheet extends StatelessWidget {
  const _NewMessageSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      // Keep the sheet above the keyboard while searching.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: AppLayout.sheetHeight(context, 0.62),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muteSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.messagesComposeTitle,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: TextField(
                  autofocus: true,
                  cursorColor: AppColors.accent,
                  onChanged: (query) => context.read<ComposeBloc>().add(
                    ComposeQueryChanged(query),
                  ),
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.messagesComposeSearchHint,
                    hintStyle: TextStyle(
                      color: AppColors.muteSoft,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.mute,
                      size: 22,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ComposeBloc, ComposeState>(
                builder: (context, state) {
                  if (state.isLoading && state.users.isEmpty) {
                    return Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }
                  if (state.users.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.messagesComposeEmpty,
                        style: TextStyle(
                          color: AppColors.mute,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(user),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              MessageAvatar(
                                username: user.username,
                                avatarUrl: user.avatarUrl,
                                size: 44,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (user.isVerified) ...const [
                                SizedBox(width: 6),
                                VerifiedBadge(size: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
