import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxService {
  static ThemeController get to => Get.find();
  
  late SharedPreferences _prefs;
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  Future<ThemeController> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? modeString = _prefs.getString('theme_mode');
    
    if (modeString == 'light') {
      _themeMode.value = ThemeMode.light;
    } else if (modeString == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.system;
    }
    
    return this;
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      _setThemeMode(ThemeMode.light);
    } else if (_themeMode.value == ThemeMode.light) {
      _setThemeMode(ThemeMode.dark);
    } else {
      // Toggle based on current brightness
      final isPlatformDark = Get.context?.theme.brightness == Brightness.dark;
      _setThemeMode(isPlatformDark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  void _setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _prefs.setString('theme_mode', mode.name);
    // Use Get.changeThemeMode to smoothly transition without full rebuild
    Get.changeThemeMode(mode);
    // Force update to ensure BottomNav and all widgets use new colors
    Future.delayed(const Duration(milliseconds: 50), () {
      Get.forceAppUpdate();
    });
  }
}
