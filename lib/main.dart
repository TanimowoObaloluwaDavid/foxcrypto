import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/onboarding_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
  ));
  runApp(const FoxcryptoApp());
}

class FoxcryptoApp extends StatelessWidget {
  const FoxcryptoApp({super.key, this.home});

  /// Optional override used by screenshot tests; defaults to onboarding.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foxcrypto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: home ?? const OnboardingScreen(),
    );
  }
}
