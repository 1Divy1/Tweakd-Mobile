import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app_layout.dart';

/// Phones stay in portrait; tablets and unfolded foldables rotate freely.
///
/// Tweakd's layouts are designed for a portrait phone, and a landscape phone
/// leaves too little height for them. A tablet is a different case: people
/// hold iPads and unfolded foldables either way, iPad multitasking requires
/// every orientation, and Android 16 ignores orientation locks on large screens
/// regardless. So the lock is decided by the window's shortest side — which
/// rotating doesn't change — and re-decided whenever the window changes, e.g.
/// when a foldable is opened or closed.
class OrientationPolicy extends StatefulWidget {
  final Widget child;

  const OrientationPolicy({super.key, required this.child});

  @override
  State<OrientationPolicy> createState() => _OrientationPolicyState();
}

class _OrientationPolicyState extends State<OrientationPolicy> {
  bool? _expanded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final expanded =
        MediaQuery.sizeOf(context).shortestSide >= AppLayout.compactMaxWidth;
    if (expanded == _expanded) return;
    _expanded = expanded;
    SystemChrome.setPreferredOrientations(
      expanded
          ? DeviceOrientation.values
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
