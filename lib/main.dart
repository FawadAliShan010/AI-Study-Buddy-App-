import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/study_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/quiz_provider.dart';
import 'core/services/local_storage_service.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCRNk55DEyEBeFw55tSi3VCNgSMqXiX55U',
      appId: '1:996544130180:ios:bc42daa318e1f332e7a6d1',
      messagingSenderId: '996544130180',
      projectId: 'ai-study-buddy-29cb6',
      storageBucket: 'ai-study-buddy-29cb6.firebasestorage.app',
      iosBundleId: 'com.example.aiStuddyBuddy'
    ),
  );
  await LocalStorageService().init();

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(isOnboardingComplete: isOnboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool isOnboardingComplete;

  const MyApp({super.key, required this.isOnboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'AI Study Buddy',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            }

            if (isOnboardingComplete) {
              return const LoginScreen();
            }

            return const OnboardingScreen();
          },
        ),
      ),
    );
  }
}