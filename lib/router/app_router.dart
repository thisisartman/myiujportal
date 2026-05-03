import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/login_page.dart';
import '../widgets/layout/app_shell.dart';
import '../pages/dashboard_page.dart';
import '../pages/calendar_page.dart';
import '../pages/facilities_hub_page.dart';
import '../pages/facilities/room_booking_page.dart';
import '../pages/facilities/library_page.dart';
import '../pages/facilities/campus_directory_page.dart';
import '../pages/wiki/wiki_home_page.dart';
import '../pages/wiki/wiki_article_page.dart';
import '../pages/profile_page.dart';
import '../pages/meeting_page.dart';
import '../providers/auth_provider.dart';

// Bridges Riverpod auth state into a ChangeNotifier so GoRouter can refresh.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<bool>(authProvider, (prev, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    refreshListenable: listenable,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider);
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CalendarPage()),
          ),
          GoRoute(
            path: '/facilities',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FacilitiesHubPage()),
            routes: [
              GoRoute(
                path: 'room-booking',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: RoomBookingPage()),
              ),
              GoRoute(
                path: 'library',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LibraryPage()),
              ),
              GoRoute(
                path: 'directory',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CampusDirectoryPage()),
              ),
            ],
          ),
          GoRoute(
            path: '/wiki',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WikiHomePage()),
          ),
          GoRoute(
            path: '/wiki/:articleId',
            pageBuilder: (context, state) {
              final articleId = state.pathParameters['articleId']!;
              return NoTransitionPage(
                child: WikiArticlePage(articleId: articleId),
              );
            },
          ),
          GoRoute(
            path: '/wiki/:category/:articleId',
            pageBuilder: (context, state) {
              final articleId =
                  '${state.pathParameters['category']!}-${state.pathParameters['articleId']!}';
              return NoTransitionPage(
                child: WikiArticlePage(articleId: articleId),
              );
            },
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
          GoRoute(
            path: '/meeting/:code',
            pageBuilder: (context, state) => NoTransitionPage(
              child: MeetingPage(code: state.pathParameters['code']!),
            ),
          ),
        ],
      ),
    ],
  );
});
