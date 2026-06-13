import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/theme.dart';

enum _AppScreen { splash, login, dashboard }

class HushGuruApp extends StatelessWidget {
  const HushGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HushGuru',
      theme: buildHushGuruTheme(),
      debugShowCheckedModeBanner: false,
      home: const _AppNavigator(),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  _AppScreen _screen = _AppScreen.splash;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    // Auto-advance from splash after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _screen = _AppScreen.login);
    });
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _AppScreen.splash:
        return const SplashScreen(key: ValueKey('splash'));
      case _AppScreen.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onLoginSuccess: () =>
              setState(() => _screen = _AppScreen.dashboard),
        );
      case _AppScreen.dashboard:
        return const DashboardScreen(key: ValueKey('dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _buildScreen(),
    );
  }
}
