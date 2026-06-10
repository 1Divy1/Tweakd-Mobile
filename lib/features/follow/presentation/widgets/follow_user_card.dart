import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/follow_list_user.dart';

class FollowUserCard extends StatelessWidget {
  final FollowListUserEntity user;
  final String query;
  final bool isFollowing;
  final bool showRemoveButton;
  final VoidCallback onTap;
  final VoidCallback onRemoveFollowerTap;
  final VoidCallback? onFollowTap;

  const FollowUserCard({
    super.key,
    required this.user,
    required this.query,
    required this.isFollowing,
    required this.showRemoveButton,
    required this.onTap,
    required this.onRemoveFollowerTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            _Avatar(avatarUrl: user.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: _HighlightedUsername(
                username: user.username,
                query: query,
              ),
            ),
            const SizedBox(width: 8),
            if (user.id != Supabase.instance.client.auth.currentUser?.id)
              if (showRemoveButton)
                _RemoveFollowerButton(onTap: onRemoveFollowerTap)
              else
                _FollowButton(isFollowing: isFollowing, onTap: onFollowTap),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;

  const _Avatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.line2,
      child: const Icon(Icons.person, size: 22, color: AppColors.muteSoft),
    );
  }
}

class _HighlightedUsername extends StatelessWidget {
  final String username;
  final String query;

  const _HighlightedUsername({required this.username, required this.query});

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        children: _buildSpans(),
      ),
    );
  }

  List<InlineSpan> _buildSpans() {
    if (query.isEmpty) return [TextSpan(text: username)];

    final lowerName = username.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    while (true) {
      final matchIdx = lowerName.indexOf(lowerQuery, start);
      if (matchIdx == -1) {
        spans.add(TextSpan(text: username.substring(start)));
        break;
      }
      if (matchIdx > start) {
        spans.add(TextSpan(text: username.substring(start, matchIdx)));
      }
      final matchEnd = matchIdx + query.length;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              username.substring(matchIdx, matchEnd),
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
      start = matchEnd;
    }

    return spans;
  }
}

class _RemoveFollowerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveFollowerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close, size: 13, color: AppColors.ink),
          SizedBox(width: 4),
          Text(
            'REMOVE',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({required this.isFollowing, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isFollowing) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check, size: 13, color: AppColors.ink),
            SizedBox(width: 4),
            Text(
              'FOLLOWING',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
      ),
      child: const Text(
        'FOLLOW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
