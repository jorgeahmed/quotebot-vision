import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/pages/dashboard_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'domain/repositories/project_repository.dart';
import 'data/repositories/mock_profile_repository.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'core/config/app_config.dart';
import 'domain/repositories/quotation_repository.dart';
import 'domain/repositories/job_repository.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

void main() async {
  debugPrint('🚀 [MAIN] Starting main()');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [MAIN] WidgetsFlutterBinding initialized');

  // Initialize Firebase (only on native platforms, not Web)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ [MAIN] Firebase initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [MAIN] Firebase initialization failed: $e');
    }
  }

  // Set Environment based on platform
  // Web: MOCK (avoids Firebase issues, reliable for demos)
  // Android/iOS: PROD (real backend with Gemini Vision)
  if (kIsWeb) {
    AppConfig().setEnvironment(Environment.mock);
    debugPrint('🌐 [MAIN] Running on Web - Using MOCK mode');
  } else {
    AppConfig().setEnvironment(Environment.prod);
    debugPrint(
        '📱 [MAIN] Running on Native - Using PROD mode with real backend');
  }

  runApp(const QuoteBotApp());
}

class QuoteBotApp extends StatelessWidget {
  const QuoteBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProjectRepository>.value(
            value: config.projectRepository),
        RepositoryProvider<QuotationRepository>(
          create: (context) => config.quotationRepository,
        ),
        RepositoryProvider<JobRepository>(
          create: (context) => config.jobRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => ProfileBloc(
                    profileRepository: kIsWeb
                        ? MockProfileRepository()
                        : ProfileRepositoryImpl(),
                  )..add(const SubscribeToProfile('demo-user-id')),
                ),
              ],
              child: MaterialApp(
                title: 'QuoteBot Vision',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2979FF), // Electric Blue
                    brightness: Brightness.light,
                    primary: const Color(0xFF2979FF),
                    secondary: const Color(0xFF00E676), // Neon Lime
                    background: Colors.white,
                    surface: Colors.grey[50],
                  ),
                  scaffoldBackgroundColor: Colors.white,
                  textTheme:
                      GoogleFonts.interTextTheme(ThemeData.light().textTheme),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2979FF),
                    brightness: Brightness.dark,
                    // High contrast colors
                    primary: const Color(0xFF64B5F6), // Lighter blue
                    secondary: const Color(0xFF69F0AE), // Bright lime
                    tertiary: const Color(0xFFFFB74D), // Orange
                    background: const Color(0xFF0A0E27), // Deep navy
                    surface: const Color(0xFF1A1F3A), // Card surface
                    surfaceVariant: const Color(0xFF2A2F4A), // Elevated
                    onPrimary: Colors.black,
                    onSecondary: Colors.black,
                    onBackground: const Color(0xFFE8EAED), // Light text
                    onSurface: const Color(0xFFE8EAED), // Light text
                    onSurfaceVariant: const Color(0xFFB8BABD), // Gray text
                    error: const Color(0xFFFF5252),
                  ),
                  scaffoldBackgroundColor: const Color(0xFF0A0E27),
                  cardColor: const Color(0xFF1A1F3A),
                  textTheme: GoogleFonts.interTextTheme(
                    ThemeData.dark().textTheme.copyWith(
                          bodyLarge: const TextStyle(color: Color(0xFFE8EAED)),
                          bodyMedium: const TextStyle(color: Color(0xFFE8EAED)),
                          titleLarge: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          titleMedium:
                              const TextStyle(color: Color(0xFFE8EAED)),
                        ),
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF1A1F3A),
                    foregroundColor: Color(0xFFE8EAED),
                    elevation: 0,
                  ),
                ),
                home: const DashboardPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
