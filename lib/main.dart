import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/app_config.dart';

// Import your models and the AuthGate
import 'auth_gate.dart';
import 'theme.dart';
import 'auth_service.dart';
import 'isar_service.dart';
import 'app_state.dart';
import 'database_seeder.dart';

// HomeScreen is not directly needed as home now, AuthGate will handle it.

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase (optional, controlled by feature flag)
  if (AppConfig.useSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  // Initialize IsarService
  final isarService = IsarService();
  // CORRECTED: Await the 'db' future to ensure the database is open before proceeding.
  await isarService.db;

  // Seed the database with our prototype data
  await DatabaseSeeder.seed(); // CORRECTLY CALL the static seed method

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<IsarService>.value(
          value: isarService,
        ), // Provide the initialized IsarService
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ), // ADDED: AppState Provider
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Sadhak',
          theme: AppTheme.light(),
          // Add these lines for localization:
          // localizationsDelegates: AppLocalizations.localizationsDelegates,
          // supportedLocales: AppLocalizations.supportedLocales,
          // locale: appState.locale,
          home: const AuthGate(),
        );
      },
    );
  }
}
