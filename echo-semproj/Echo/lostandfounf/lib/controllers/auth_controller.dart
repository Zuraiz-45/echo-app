import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // Only for signup
  final studentIdController = TextEditingController(); // Only for signup

  final isLogin = true.obs;
  final isLoading = false.obs;

  void toggleMode() {
    isLogin.value = !isLogin.value;
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
    } else {
      success = await AuthService.to.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        studentId: studentIdController.text.trim(),
      );
    }

    isLoading.value = false;

    if (success) {
      Get.offAll(() => const MainLayout());
    }
    // Error handling is done inside AuthService methods with Snackbars
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