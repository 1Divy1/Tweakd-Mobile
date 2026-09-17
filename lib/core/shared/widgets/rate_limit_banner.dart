import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../network/rate_limit_notifier.dart';
import '../../theme/app_colors.dart';

/// Wraps the whole app (mounted in `MaterialApp.router`'s `builder`) and slides
/// a "you're doing that too fast" banner in from the top whenever
/// [notices] emits — i.e. whenever the backend answered `429`.
///
/// It only explains *why*; whatever the screen itself shows for the failed
/// request (a rolled-back like, an error view) still happens as before. The
/// banner hides itself after [visibleFor], or on tap / swipe up, and never
/// blocks touches while hidden.
class RateLimitBanner extends StatefulWidget {
  final Stream<RateLimitNotice> notices;
  final Widget child;

  /// How long a notice stays on screen.
  static const visibleFor = Duration(seconds: 4);

  const RateLimitBanner({
    super.key,
    required this.notices,
    required this.child,
  });

  @override
  State<RateLimitBanner> createState() => _RateLimitBannerState();
}

class _RateLimitBannerState extends State<RateLimitBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  StreamSubscription<RateLimitNotice>? _subscription;
  Timer? _hideTimer;
  RateLimitNotice? _notice;

  @override
  void initState() {
    super.initState();
    _subscription = widget.notices.listen(_show);
  }

  @override
  void didUpdateWidget(RateLimitBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notices != widget.notices) {
      _subscription?.cancel();
      _subscription = widget.notices.listen(_show);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _show(RateLimitNotice notice) {
    if (!mounted) return;
    setState(() => _notice = notice);
    _controller.forward();
    _hideTimer?.cancel();
    _hideTimer = Timer(RateLimitBanner.visibleFor, _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (mounted) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final notice = _notice;
              if (notice == null || _controller.isDismissed) {
                return const SizedBox.shrink();
              }
              return SlideTransition(
                position: _slide,
                child: _BannerCard(notice: notice, onDismiss: _hide),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final RateLimitNotice notice;
  final VoidCallback onDismiss;

  const _BannerCard({required this.notice, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Center(
          child: ConstrainedBox(
            // Reads as a banner, not a stretched bar, on tablets.
            constraints: const BoxConstraints(maxWidth: 560),
            child: GestureDetector(
              onTap: onDismiss,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < 0) onDismiss();
              },
              child: Semantics(
                liveRegion: true,
                child: Material(
                  color: AppColors.ink,
                  elevation: 6,
                  shadowColor: AppColors.shadow,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: AppColors.inkPanel,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.rateLimitTitle,
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.inkPanel,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rateLimitRetryMessage(l10n, notice.retryAfter),
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkPanel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Try again in …" in the largest unit that fits, rounded up so the user is
/// never told a shorter wait than the backend asked for.
String rateLimitRetryMessage(AppLocalizations l10n, Duration? retryAfter) {
  if (retryAfter == null || retryAfter <= Duration.zero) {
    return l10n.rateLimitRetrySoon;
  }
  final seconds = (retryAfter.inMilliseconds / 1000).ceil();
  if (seconds < 60) return l10n.rateLimitRetryInSeconds(seconds);
  if (seconds < 3600) {
    return l10n.rateLimitRetryInMinutes((seconds / 60).ceil());
  }
  return l10n.rateLimitRetryInHours((seconds / 3600).ceil());
}
