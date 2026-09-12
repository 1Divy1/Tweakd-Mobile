import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/message.dart';
import '../shared/message_avatar.dart';
import 'bubble_entrance.dart';

/// A post shared into the chat: a white card with the post author's handle,
/// the image (placeholder block when the mock has no URL) and the caption.
class SharedPostBubble extends StatelessWidget {
  final MessageEntity message;
  final bool animate;

  const SharedPostBubble({
    super.key,
    required this.message,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final post = message.sharedPost!;

    return BubbleEntrance(
      animate: animate,
      fromRight: mine,
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 260,
          margin: EdgeInsets.only(
            top: 3,
            bottom: 3,
            left: mine ? 60 : 16,
            right: mine ? 16 : 60,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    MessageAvatar(
                      username: post.authorUsername,
                      avatarUrl: post.authorAvatarUrl,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '@${post.authorUsername}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _PostImage(imageUrl: post.imageUrl),
              if (post.caption != null && post.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Text(
                    post.caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink2,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
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

class _PostImage extends StatelessWidget {
  final String? imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return AspectRatio(
      aspectRatio: 1.35,
      child: url != null
          ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
          : Container(
              // Placeholder until real posts carry image URLs.
              color: const Color(0xFF6FB5B5),
              alignment: Alignment.center,
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 72,
                color: AppColors.ink.withValues(alpha: 0.75),
              ),
            ),
    );
  }
}
