import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/activity_detail/activity_detail_screen.dart';
import 'features/home/home_screen.dart';
import 'features/recording/recording_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/recording',
      builder: (_, __) => const RecordingScreen(),
    ),
    GoRoute(
      path: '/activity/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ActivityDetailScreen(activityId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'First Klick',
      theme: buildAppTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
