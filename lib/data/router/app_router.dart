import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/presentation/pages/game_page.dart';
import 'package:plane_dash/presentation/pages/records_page.dart';
import 'package:plane_dash/presentation/pages/training_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/game',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/game',
          pageBuilder: (context, state) => NoTransitionPage(child: GamePage()),
        ),
        // GoRoute(
        //   path: '/garage',
        //   pageBuilder: (context, state) => NoTransitionPage(child: GaragePage()),
        // ),
        GoRoute(
          path: '/records',
          pageBuilder: (context, state) => NoTransitionPage(child: RecordsPage()),
        ),
        GoRoute(
          path: '/training',
          pageBuilder: (context, state) => NoTransitionPage(child: TrainingPage()),
        ),
        // GoRoute(
        //   path: '/profile',
        //   pageBuilder: (context, state) => NoTransitionPage(child: ProfilePage()),
        // ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedItemColor: AppColors.accentRed,
        unselectedItemColor: Colors.grey,
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Игра'),
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Гараж'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Рекорды'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Тренировка'),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    // if (location.startsWith('/garage')) return 1;
    if (location.startsWith('/records')) return 1;
    // if (location.startsWith('/training')) return 3;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/game');
        break;
      // case 1:
      //   context.go('/garage');
      //   break;
      case 1:
        context.go('/records');
        break;
      case 2:
        context.go('/training');
        break;
      // case 4:
      //   context.go('/profile');
      //   break;
    }
  }
}