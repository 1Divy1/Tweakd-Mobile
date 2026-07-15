import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The message composer: attach button, rounded text field with an emoji
/// affordance, and the orange send button (spring-scales on tap).
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onAttach;

  const ChatInputBar({super.key, required this.onSend, required this.onAttach});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _sendPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void dispose() {
    _controller.dispose();
    _sendPop.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
    _sendPop
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: AppColors.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: widget.onAttach,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.ink, size: 26),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      cursorColor: AppColors.accent,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.messagesInputHint,
                        hintStyle: const TextStyle(
                          color: AppColors.muteSoft,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(18, 12, 4, 12),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12, bottom: 12),
                    child: Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: AppColors.mute,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: ScaleTransition(
              scale: TweenSequence<double>([
                TweenSequenceItem(
                    tween: Tween(begin: 1, end: 0.82), weight: 35),
                TweenSequenceItem(
                    tween: Tween(begin: 0.82, end: 1), weight: 65),
              ]).animate(CurvedAnimation(
                parent: _sendPop,
                curve: Curves.easeOutBack,
              )),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
