import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/session_check/cubit.dart';
import '../bloc/session_check/state.dart';

/// Moves the user off an optimistic launch when [SessionCheckCubit] finds it
/// was wrong. Sits above the router (the root of the app), so it navigates
/// through [navigate] rather than a `BuildContext` inside a route.
class SessionCheckListener extends StatelessWidget {
  /// Replaces the whole stack with the given location (`GoRouter.go`).
  final void Function(String location) navigate;
  final Widget child;

  const SessionCheckListener({
    super.key,
    required this.navigate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCheckCubit, SessionCheckState>(
      listener: (context, state) => switch (state) {
        SessionCheckRequiresOnboarding() => navigate('/onboarding'),
        SessionCheckSignedOut() => navigate('/signup'),
        SessionCheckPending() => null,
      },
      child: child,
    );
  }
}
