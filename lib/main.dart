import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ ADDED
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/study_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/quiz_provider.dart';
import 'core/providers/theme_provider.dart'; // ✅ Add this import
import 'core/services/local_storage_service.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ LOAD ENV FILE
  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyCRNk55DEyEBeFw55tSi3VCNgSMqXiX55U',
        authDomain: 'ai-study-buddy-29cb6.firebaseapp.com',
        appId: '1:996544130180:ios:bc42daa318e1f332e7a6d1',
        messagingSenderId: '996544130180',
        projectId: 'ai-study-buddy-29cb6',
        storageBucket: 'ai-study-buddy-29cb6.firebasestorage.app',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

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
        // ✅ Add ThemeProvider here - MUST BE FIRST
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'AI Study Buddy',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}