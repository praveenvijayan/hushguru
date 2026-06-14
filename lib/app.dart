import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

class HushGuruApp extends StatelessWidget {
  const HushGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HushGuru',
      theme: buildHushGuruTheme(),
      debugShowCheckedModeBanner: false,
      home: const AppNavigator(),
    );
  }
}

/// Top-level auth router. [authStream] is exposed for widget tests only;
/// production callers use the no-arg constructor.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key, @visibleForTesting this.authStream});

  final Stream<User?>? authStream;

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _splashDone = false;
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = widget.authStream ?? FirebaseAuth.instance.authStateChanges();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return const SplashScreen(key: ValueKey('splash'));
    }
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(key: ValueKey('auth-check'));
        }
        if (snapshot.data != null) {
          return const DashboardScreen(key: ValueKey('dashboard'));
        }
        return const LoginScreen(key: ValueKey('login'));
      },
    );
  }
}
