import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // Only for signup
  final studentIdController = TextEditingController(); // Only for signup

  final isLogin = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedCredentials();
  }

  /// Load saved email from SharedPreferences if "Remember Me" was checked
  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email') ?? '';
    final wasRemembered = prefs.getBool('remember_me') ?? false;
    if (wasRemembered && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  /// Save or clear remembered email based on toggle
  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('remembered_email', emailController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.setBool('remember_me', false);
    }
  }

  void toggleMode() {
    isLogin.value = !isLogin.value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    if (!isLogin.value && nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }

    if (!isLogin.value && studentIdController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your student ID');
      return;
    }

    isLoading.value = true;

    bool success;
    if (isLogin.value) {
      success = await AuthService.to.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        // Save or clear remembered email
        await _handleRememberMe();
        isLoading.value = false;
        Get.offAll(() => const MainLayout());
      } else {
        isLoading.value = false;
      }
    } else {
      // Sign up
      success = await AuthService.to.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        studentId: studentIdController.text.trim(),
      );

      isLoading.value = false;

      if (success) {
        // Sign out so user must explicitly log in
        await AuthService.to.signOut();

        // Switch to login mode with email pre-filled
        isLogin.value = true;
        passwordController.clear();
        nameController.clear();
        studentIdController.clear();

        Get.snackbar(
          'Account Created!',
          'Please log in with your new credentials.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    studentIdController.dispose();
    super.onClose();
  }
}