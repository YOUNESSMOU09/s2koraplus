import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/presentation/providers/router_providers.dart';
import 'package:marma/presentation/screens/common/not_found_screen.dart';
import 'package:marma/presentation/screens/following/following_screen.dart';
import 'package:marma/presentation/screens/following/manage_favourites_screen.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/presentation/screens/journal/journal_index_screen.dart';
import 'package:marma/presentation/screens/journal/journal_screen.dart';
import 'package:marma/presentation/screens/live/live_screen.dart';
import 'package:marma/presentation/screens/match_detail/match_detail_screen.dart';
import 'package:marma/presentation/screens/matches/matches_screen.dart';
import 'package:marma/presentation/screens/search/search_screen.dart';
import 'package:marma/presentation/screens/settings/about_screen.dart';
import 'package:marma/presentation/screens/settings/choice_screens.dart';
import 'package:marma/presentation/screens/settings/settings_screen.dart';
import 'package:marma/presentation/screens/shell/home_shell.dart';
import 'package:marma/presentation/screens/splash/splash_screen.dart';
import 'package:marma/presentation/theme/app_motion.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod state into `GoRouter.refreshListenable`.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen<bool>(splashGateProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final _RouterRefresh refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppEnv.hasDevRoute ? AppEnv.devRoute : '/splash',
    refreshListenable: refresh,
    errorBuilder: (BuildContext context, GoRouterState state) => const NotFoundScreen(),
    redirect: (BuildContext context, GoRouterState state) {
      if (AppEnv.hasDevRoute) return null;
      final bool splashDone = ref.read(splashGateProvider);
      final String location = state.matchedLocation;

      if (!splashDone) return location == '/splash' ? null : '/splash';
      if (location == '/splash') return '/matches';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionDuration: AppMotion.quick,
          reverseTransitionDuration: AppMotion.fast,
          transitionsBuilder: (_, Animation<double> animation, _, Widget child) =>
              FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.99, end: 1).animate(animation),
              child: child,
            ),
          ),
        ),
      ),
      GoRoute(
        // The journal is a full-screen workspace, outside the shell, so the
        // bottom nav cannot steal a tap while someone is typing into it.
        path: '/journal/:targetType/:targetId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => JournalScreen(
          targetType: JournalTargetType.fromId(state.pathParameters['targetType']),
          targetId: state.pathParameters['targetId'] ?? '',
          fallbackTitle: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(
        path: '/match/:fixtureId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['fixtureId'] ?? '';
          // `extra` is null on a cold start / deep link; the screen resolves the
          // fixture from the caches instead (§7.3).
          final Object? extra = state.extra;
          return MatchDetailScreen(
            fixtureId: id,
            initial: extra is Fixture ? extra : null,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
                StatefulNavigationShell shell) =>
            HomeShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/matches',
                builder: (BuildContext context, GoRouterState state) => MatchesScreen(
                  day: DayKey.fromName(state.uri.queryParameters['day']),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/live',
                // A query parameter, not a new route: the same precedent
                // `/matches?day=` already sets, so the selection survives
                // state restoration and a nav re-tap resets it for free.
                builder: (BuildContext context, GoRouterState state) => LiveScreen(
                  view: LiveView.fromName(state.uri.queryParameters['view']),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/following',
                builder: (BuildContext context, GoRouterState state) =>
                    const FollowingScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'manage',
                    builder: (BuildContext context, GoRouterState state) =>
                        const ManageFavouritesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/journals',
                builder: (BuildContext context, GoRouterState state) =>
                    const JournalIndexScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'appearance',
                    builder: (BuildContext context, GoRouterState state) =>
                        const AppearanceScreen(),
                  ),
                  GoRoute(
                    path: 'language',
                    builder: (BuildContext context, GoRouterState state) =>
                        const LanguageScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (BuildContext context, GoRouterState state) =>
                        const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
