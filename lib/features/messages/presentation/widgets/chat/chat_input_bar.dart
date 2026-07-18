import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/message.dart';
import 'car_picker_sheet.dart';
import 'tagged_car_chips.dart';

/// The message composer: a car-share button, rounded text field with an emoji
/// toggle, and the orange send button (spring-scales on tap). Tapping the
/// emoji button swaps the keyboard for an in-app emoji panel (and back);
/// tapping the field re-opens the keyboard. Picked emoji insert at the
/// cursor via the field's controller. The car button opens a picker of the
/// viewer's garage; chosen cars appear as removable chips above the input and
/// are sent alongside the text. The send button enables when there's text OR
/// at least one staged car.
/// [onSend] receives the trimmed text and the staged cars; [onTextChanged]
/// reports every text edit — it drives the typing signal.
class ChatInputBar extends StatefulWidget {
  final void Function(String text, List<DmTaggedCarEntity> cars) onSend;
  final ValueChanged<String>? onTextChanged;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onTextChanged,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showEmoji = false;

  /// Cars staged for the next send, in share order.
  final List<DmTaggedCarEntity> _selectedCars = [];

  /// Mirrors whether the field currently holds non-blank text — drives the
  /// send button's enabled look. Synced from a controller listener so
  /// programmatic edits (the emoji panel inserts via the controller) count
  /// too, not just keyboard input.
  bool _hasText = false;

  bool get _canSend => _hasText || _selectedCars.isNotEmpty;

  late final AnimationController _sendPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncHasText);
    // Keyboard gaining focus always wins over the emoji panel.
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  void _syncHasText() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendPop.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    final cars = List<DmTaggedCarEntity>.from(_selectedCars);
    if (text.isEmpty && cars.isEmpty) return;
    _controller.clear();
    widget.onTextChanged?.call('');
    widget.onSend(text, cars);
    setState(() => _selectedCars.clear());
    _sendPop
      ..reset()
      ..forward();
  }

  void _onTextChanged(String value) {
    widget.onTextChanged?.call(value);
  }

  Future<void> _openCarPicker() async {
    // Close any open keyboard/emoji panel so the sheet gets the full height.
    _focusNode.unfocus();
    if (_showEmoji) setState(() => _showEmoji = false);
    final result = await showCarPickerSheet(
      context,
      initialSelected: _selectedCars,
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedCars
        ..clear()
        ..addAll(result);
    });
  }

  void _removeCar(DmTaggedCarEntity car) {
    setState(() => _selectedCars.removeWhere((c) => c.id == car.id));
  }

  /// Swap between the keyboard and the emoji panel.
  void _toggleEmoji() {
    if (_showEmoji) {
      // Panel → keyboard.
      setState(() => _showEmoji = false);
      _focusNode.requestFocus();
    } else {
      // Keyboard → panel. Drop focus so the soft keyboard closes; the panel
      // then fills the freed space. The controller keeps its selection, so
      // emoji still insert at the cursor.
      _focusNode.unfocus();
      setState(() => _showEmoji = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedCars.isNotEmpty)
          TaggedCarChips(cars: _selectedCars, onRemove: _removeCar),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          color: AppColors.bg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _openCarPicker,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car_outlined,
                      color: AppColors.ink, size: 24),
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
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          onChanged: _onTextChanged,
                          onTap: () {
                            if (_showEmoji) {
                              setState(() => _showEmoji = false);
                            }
                          },
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
                      GestureDetector(
                        onTap: _toggleEmoji,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 12),
                          child: Icon(
                            _showEmoji
                                ? Icons.keyboard_outlined
                                : Icons.sentiment_satisfied_alt_outlined,
                            color: _showEmoji
                                ? AppColors.accent
                                : AppColors.mute,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _canSend ? _send : null,
                child: ScaleTransition(
                  scale: TweenSequence<double>([
                    TweenSequenceItem(
                        tween: Tween(begin: 1, end: 0.82), weight: 35),
                    TweenSequenceItem(
                        tween: Tween(begin: 0.82, end: 1), weight: 65),
                  ]).animate(CurvedAnimation(
                    parent: _sendPop,
                    // TweenSequence asserts t stays in [0,1]; overshooting
                    // curves like easeOutBack would break it. The pop lives in
                    // the tween.
                    curve: Curves.easeOut,
                  )),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _canSend ? AppColors.accent : AppColors.muteSoft,
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
        ),
        if (_showEmoji) _EmojiPanel(controller: _controller, onChanged: _onEmojiChanged),
      ],
    );
  }

  void _onEmojiChanged() => widget.onTextChanged?.call(_controller.text);
}

/// The in-app emoji keyboard, styled to blend with the app. The bottom action
/// bar (with its foreign-looking search field) is disabled; picked emoji are
/// inserted into [controller] at the cursor by the package itself.
class _EmojiPanel extends StatelessWidget {
  static const double _height = 280;

  final TextEditingController controller;
  final VoidCallback onChanged;

  const _EmojiPanel({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: EmojiPicker(
        textEditingController: controller,
        onEmojiSelected: (_, _) => onChanged(),
        onBackspacePressed: onChanged,
        config: Config(
          height: _height,
          emojiViewConfig: const EmojiViewConfig(
            backgroundColor: AppColors.bg,
            columns: 8,
            emojiSizeMax: 28,
            buttonMode: ButtonMode.MATERIAL,
          ),
          categoryViewConfig: const CategoryViewConfig(
            backgroundColor: AppColors.bg,
            indicatorColor: AppColors.accent,
            iconColor: AppColors.muteSoft,
            iconColorSelected: AppColors.accent,
            backspaceColor: AppColors.accent,
            dividerColor: AppColors.line,
            tabBarHeight: 44,
          ),
          skinToneConfig: const SkinToneConfig(
            dialogBackgroundColor: AppColors.surface,
            indicatorColor: AppColors.line,
          ),
          // The search bar / bottom bar looks foreign — hide it entirely.
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
        ),
      ),
    );
  }
}
