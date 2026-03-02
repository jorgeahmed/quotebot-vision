import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/pages/main_navigation_page.dart'; // Import new navigation page

import 'package:flutter_bloc/flutter_bloc.dart';
import 'domain/repositories/project_repository.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'core/config/app_config.dart';
import 'domain/repositories/quotation_repository.dart';
import 'domain/repositories/job_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

void main() async {
  debugPrint('🚀 [MAIN] Starting main()');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [MAIN] WidgetsFlutterBinding initialized');

  // Initialize Firebase on ALL platforms (including Web)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ [MAIN] Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ [MAIN] Firebase initialization failed: $e');
  }

  // All platforms use PROD mode (real backend + Firestore)
  AppConfig().setEnvironment(Environment.prod);
  debugPrint('🚀 [MAIN] Running in PROD mode with real backend');

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
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
      ],
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => AuthBloc(
                    authRepository: context.read<AuthRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => ProfileBloc(
                    profileRepository: ProfileRepositoryImpl(),
                  )..add(const SubscribeToProfile('demo-user-id')),
                ),
                BlocProvider(
                  create: (context) => ChatBloc(AppConfig().chatRepository),
                ),
              ],
              child: MaterialApp(
                title: 'QuoteBot Vision',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2979FF),
                    brightness: Brightness.light,
                    primary: const Color(0xFF2979FF),
                    secondary: const Color(0xFF00E676),
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
                    tertiary: const Color(0xFFF59E0B),
                    background: const Color(0xFF0A0E27),
                    surface: const Color(0xFF111633),
                    surfaceVariant: const Color(0xFF1A1F3A),
                    onPrimary: Colors.white,
                    onSecondary: Colors.black,
                    onBackground: const Color(0xFFE8EAED),
                    onSurface: const Color(0xFFE8EAED),
                    onSurfaceVariant: const Color(0xFF8B8FA3),
                    error: const Color(0xFFFF5252),
                    outline: const Color(0xFF1E2447),
                  ),
                  scaffoldBackgroundColor: const Color(0xFF0A0E27),
                  cardColor: const Color(0xFF111633),
                  dividerColor: const Color(0xFF1E2447),
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
                    backgroundColor: Color(0xFF0A0E27),
                    foregroundColor: Color(0xFFE8EAED),
                    elevation: 0,
                  ),
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: const Color(0xFF111633),
                    indicatorColor: const Color(0xFF2979FF).withOpacity(0.15),
                    iconTheme: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const IconThemeData(color: Color(0xFF2979FF));
                      }
                      return const IconThemeData(color: Color(0xFF8B8FA3));
                    }),
                    labelTextStyle: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const TextStyle(
                            color: Color(0xFF2979FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600);
                      }
                      return const TextStyle(
                          color: Color(0xFF8B8FA3), fontSize: 12);
                    }),
                  ),
                ),
                home:
                    const MainNavigationPage(), // Auth desactivada temporalmente para dev
              ),
            );
          },
        ),
      ),
    );
  }
}
