import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/signup_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SignUpPage(),
    ),
  ],
);