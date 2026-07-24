import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AI Study Buddy';
  static const String appVersion = '1.0.0';

  // API Keys
  static const String groqApiKey = 'YOUR_GROQ_API_KEY';

  // Collection Names
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';
  static const String quizzesCollection = 'quizzes';
  static const String chatHistoryCollection = 'chat_history';

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 500);

  // Padding & Spacing
  static const double defaultPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 24.0;

  // Border Radius
  static const double defaultRadius = 16.0;
  static const double largeRadius = 24.0;
  static const double extraLargeRadius = 32.0;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF3F3D9E),
      Color(0xFF1A1A3E),
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D4FF),
      Color(0xFF7B2FBE),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );
}

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF3F3D9E);
  static const Color primaryLight = Color(0xFF9D97FF);

  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryDark = Color(0xFF0099CC);

  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  static const Color background = Color(0xFF0A0A1A);
  static const Color backgroundLight = Color(0xFF1A1A3E);
  static const Color surface = Color(0xFF1E1E3F);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0D0);
  static const Color textMuted = Color(0xFF6B6B8D);

  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0x1AFFFFFF);
}

class AppShadows {
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x336C63FF),
      blurRadius: 20,
      spreadRadius: 5,
    ),
  ];

  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> neon = [
    BoxShadow(
      color: Color(0x4D6C63FF),
      blurRadius: 15,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x336C63FF),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];
}