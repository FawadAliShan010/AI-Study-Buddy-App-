import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/study_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/quiz_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/upload_provider.dart'; // ✅ ADD THIS
import 'core/providers/user_profile_provider.dart'; // ✅ ADD THIS
import 'core/services/local_storage_service.dart';
import 'core/config/supabase_config.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    print('✅ Firebase initialized');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized');
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()), // ✅ ADD THIS
        ChangeNotifierProvider(create: (_) => UserProfileProvider()), // ✅ ADD THIS
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