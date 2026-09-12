import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../entities/search_result.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResultEntity result;
  final String query;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
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
            _Avatar(avatarUrl: result.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: _HighlightedUsername(
                username: result.username,
                query: query,
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: Icon(
                Icons.chevron_right,
                color: AppColors.mute,
                size: 22,
              ),
              splashRadius: 22,
            ),
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
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _AvatarPlaceholder(),
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
      child: Icon(
        Icons.person,
        size: 22,
        color: AppColors.muteSoft,
      ),
    );
  }
}

class _HighlightedUsername extends StatelessWidget {
  final String username;
  final String query;

  const _HighlightedUsername({required this.username, required this.query});

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans();
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        children: spans,
      ),
    );
  }

  List<InlineSpan> _buildSpans() {
    if (query.isEmpty) {
      return [TextSpan(text: username)];
    }

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
              style: TextStyle(
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
