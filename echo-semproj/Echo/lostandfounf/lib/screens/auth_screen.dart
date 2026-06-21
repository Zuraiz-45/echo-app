import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/colors.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              
              // App Logo Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Echo',
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Campus Lost and Found',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 36),
              
              // Login Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!controller.isLogin.value) ...[
                      Text('Full Name', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.nameController,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 15),
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: 'John Doe',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[500]),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Student ID', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.studentIdController,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 15),
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'SP24-BCS-111',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                          prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey[500]),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('University Email', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.emailController,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 15),
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'student.name@university.edu',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                        Text('Forgot Password?', style: context.theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 15, letterSpacing: 0.2),
                      cursorColor: AppColors.primary,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 2),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                        suffixIcon: Icon(Icons.visibility_outlined, color: Colors.grey[500]),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: controller.isLoading.value ? null : () => controller.submit(),
                        child: controller.isLoading.value 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(controller.isLogin.value ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        )
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.toggleMode,
                        child: Text(controller.isLogin.value ? 'Create Account' : 'Back to Login', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )),
              ),

              const SizedBox(height: 24),
              
              // Biometrics & QR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAECEF),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fingerprint, color: Colors.black87, size: 18),
                            const SizedBox(width: 8),
                            const Text('Biometrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAECEF),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner, color: Colors.black87, size: 18),
                            const SizedBox(width: 8),
                            const Text('Student QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      )
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Footer Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Restricted to University Students Only',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}