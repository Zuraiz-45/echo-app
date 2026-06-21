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
import 'screens/splash_screen.dart';
import 'controllers/theme_controller.dart';

// --- MODIFIED TO ASYNC ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- ADDED FIREBASE INITIALIZATION ---
  await Firebase.initializeApp(
    options: _firebaseOptionsForCurrentPlatform(),
  );
  
  // Initialize Persistent Theme
  await Get.putAsync(() => ThemeController().init());
  
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
      themeMode: ThemeController.to.themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const SplashScreen(),
    );
  }

  /// Light Theme Configuration
  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryLight,
        secondary: AppColors.primaryLight,
        tertiary: AppColors.foundLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      dialogBackgroundColor: AppColors.dialogLight,
      dividerColor: AppColors.dividerLight,
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryLight,
        selectionColor: Color(0x332563EB),
        selectionHandleColor: AppColors.primaryLight,
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
        backgroundColor: AppColors.primaryDarkLight,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
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
        primary: AppColors.primaryDarkVal,
        secondary: AppColors.primaryDarkVal,
        tertiary: AppColors.foundDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      dialogBackgroundColor: AppColors.dialogDark,
      dividerColor: AppColors.dividerDark,
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDarkVal, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryDarkVal,
        selectionColor: Color(0x333B82F6),
        selectionHandleColor: AppColors.primaryDarkVal,
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
        backgroundColor: AppColors.primaryDarkDark,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}