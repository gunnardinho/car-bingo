import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/play/play_screen.dart';

/// App routes. `/board/:boardId` and `/join/:code` are registered now but inert
/// — the seam costs ~nothing and makes later sharing purely additive (§3).
GoRouter buildRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/play', builder: (context, state) => const PlayScreen()),
        GoRoute(path: '/board/:boardId', builder: (context, state) => const PlayScreen()),
        GoRoute(
          path: '/join/:code',
          builder: (context, state) =>
              _Inert(label: 'Join ${state.pathParameters['code']}'),
        ),
      ],
    );

/// Placeholder for a deferred (async multiplayer) route.
class _Inert extends StatelessWidget {
  final String label;
  const _Inert({required this.label});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
