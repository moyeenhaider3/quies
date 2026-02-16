import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/user_preferences_service.dart';
import '../../features/music/presentation/bloc/quote_music_bloc.dart';
import '../../features/music/presentation/pages/genre_selection_screen.dart';
import '../../features/music/presentation/pages/quote_music_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/quotes/presentation/bloc/feed_bloc.dart';
import '../../features/quotes/presentation/pages/bookmarks_screen.dart';
import '../../features/quotes/presentation/pages/quote_feed_screen.dart';
import '../../features/quotes/presentation/pages/settings_screen.dart';
import '../di/injection.dart';
import '../network/api_logger.dart';
import '../network/quotable_dns_override.dart' show QuotableDnsInterceptor;

@module
abstract class RegisterModule {
  @singleton
  GoRouter router(UserPreferencesService preferences) => GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isCompleted = preferences.onboardingCompleted;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!isCompleted && !isGoingToOnboarding) {
        return '/onboarding';
      }

      if (isCompleted && isGoingToOnboarding) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => getIt<FeedBloc>()
              ..add(LoadFeed())
              ..add(LoadTags()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const QuoteFeedScreen(),
          ),
          GoRoute(
            path: '/bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Music MVP routes — wrapped in their own ShellRoute for shared QuoteMusicBloc
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => getIt<QuoteMusicBloc>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/genres',
            builder: (context, state) => const GenreSelectionScreen(),
          ),
          GoRoute(
            path: '/quote-music',
            builder: (context, state) => const QuoteMusicScreen(),
          ),
        ],
      ),
    ],
  );

  @preResolve
  @Named('userBox')
  Future<Box<dynamic>> get userBox => Hive.openBox<dynamic>('userBox');

  @preResolve
  @Named('adFrequencyBox')
  Future<Box<dynamic>> get adFrequencyBox =>
      Hive.openBox<dynamic>('adFrequency');

  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => true,
      ),
    );
    dio.interceptors.add(QuotableDnsInterceptor());
    dio.interceptors.add(ApiLoggerInterceptor());
    return dio;
  }
}
