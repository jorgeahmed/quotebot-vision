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
                    primary: const Color(0xFF2979FF),
                    secondary: const Color(0xFF00E676),
                    background: const Color(0xFF0F172A), // Midnight Blue
                    surface: const Color(0xFF1E293B),
                  ),
                  scaffoldBackgroundColor: const Color(0xFF0F172A),
                  textTheme:
                      GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.transparent,
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
