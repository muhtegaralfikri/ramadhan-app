import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
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
    return HomeScreen(
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
