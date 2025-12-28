import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/supabase_config.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  // Initialize locale for date formatting
  await initializeDateFormatting('id_ID');

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  final bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();

    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      if (data.session != null) {
        setState(() {
          _isAdmin = true;
        });
      } else {
        setState(() {
          _isAdmin = false;
        });
      }
    });
  }

  void _checkAuthStatus() {
    setState(() {
      _isAdmin = _authService.isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash
        ? const SplashScreen()
        : HomeScreen(
            isAdmin: _isAdmin,
            onLoginSuccess: () {
              setState(() {
                _isAdmin = true;
              });
            },
            onLogout: () {
              setState(() {
                _isAdmin = false;
              });
            },
          );
  }
}
