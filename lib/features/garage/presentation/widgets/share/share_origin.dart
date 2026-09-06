import 'package:flutter/widgets.dart';

/// The widget's rectangle in global coordinates — what
/// `ShareParams.sharePositionOrigin` wants so an iPad can anchor the share
/// popover to the control that opened it. Null when the box is not laid out,
/// which every platform but iPad ignores.
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
