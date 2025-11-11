import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindmosaic/screens/onboarding.dart';
import 'package:mindmosaic/screens/home.dart';
import 'package:mindmosaic/themes/app_themes.dart';
import 'package:mindmosaic/providers/theme_provider.dart';
import 'package:mindmosaic/providers/mood_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode)),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MindMosaic',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: hasCompletedOnboarding ? '/' : '/onboarding',
      routes: {
        '/': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}