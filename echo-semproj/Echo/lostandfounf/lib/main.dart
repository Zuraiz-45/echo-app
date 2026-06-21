import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

// --- ADDED FIREBASE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/storage_service.dart';
// ------------------------------

import 'theme/colors.dart';
import 'screens/auth_screen.dart';

// --- MODIFIED TO ASYNC ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- ADDED FIREBASE INITIALIZATION ---
  await Firebase.initializeApp(
    options: _firebaseOptionsForCurrentPlatform(),
  );
  
  // Initialize Services
  Get.put(StorageService());
  Get.put(DatabaseService());
  Get.put(AuthService());
  // -------------------------------------

  runApp(const EchoApp());
}

FirebaseOptions _firebaseOptionsForCurrentPlatform() {
  if (kIsWeb) {
    return DefaultFirebaseOptions.web;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return DefaultFirebaseOptions.android;
    case TargetPlatform.iOS:
      return DefaultFirebaseOptions.ios;
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return DefaultFirebaseOptions.web;
    default:
      return DefaultFirebaseOptions.web;
  }
}

class EchoApp extends StatelessWidget {
  const EchoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Echo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Dynamically detects system theme
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const AuthScreen(),
    );
  }

  /// Light Theme Configuration
  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      dialogBackgroundColor: AppColors.dialogLight,
      dividerColor: AppColors.dividerLight,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: AppColors.inputFill,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x331434A4),
        selectionHandleColor: AppColors.primary,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.urbanist(color: AppColors.textLight),
        bodyMedium: GoogleFonts.urbanist(color: AppColors.textLightSecondary),
        titleLarge: GoogleFonts.urbanist(
          color: AppColors.textLight, 
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Dark Theme Configuration
  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      dialogBackgroundColor: AppColors.dialogDark,
      dividerColor: AppColors.dividerDark,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: AppColors.surfaceDark,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x331434A4),
        selectionHandleColor: AppColors.primary,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.urbanist(color: AppColors.textDark),
        bodyMedium: GoogleFonts.urbanist(color: AppColors.textDarkSecondary),
        titleLarge: GoogleFonts.urbanist(
          color: AppColors.textDark, 
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}