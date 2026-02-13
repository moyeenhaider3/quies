import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use bundled fonts instead of fetching at runtime (fixes release builds)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Dependency Injection
  await configureDependencies();

  // Initialize Notifications
  await getIt<NotificationService>().init();

  runApp(const QuiesApp());
}

class QuiesApp extends StatelessWidget {
  const QuiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<GoRouter>();

    return BlocProvider(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Quies',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
