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
                child: Icon(Icons.school, size: 36, color: AppColors.primary),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(AppColors.isDark ? 0.2 : 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signup-only fields
                    if (!controller.isLogin.value) ...[
                      Text('Full Name', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.nameController,
                        style: TextStyle(color: AppColors.text, fontSize: 15),
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.name,
                        decoration: _inputDecoration(
                          hint: 'John Doe',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Student ID', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.studentIdController,
                        style: TextStyle(color: AppColors.text, fontSize: 15),
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hint: 'SP24-BCS-111',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Email field
                    Text('University Email', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.emailController,
                      style: TextStyle(color: AppColors.text, fontSize: 15),
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hint: 'student.name@university.edu',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password label row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                        if (controller.isLogin.value)
                          Text('Forgot Password?', style: context.theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Password field with visibility toggle
                    Obx(() => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      style: TextStyle(color: AppColors.text, fontSize: 15, letterSpacing: 0.2),
                      cursorColor: AppColors.primary,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.submit(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), letterSpacing: 2),
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondaryText),
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.isDark ? AppColors.background : AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )),

                    // Remember Me (login only)
                    if (controller.isLogin.value) ...[
                      const SizedBox(height: 16),
                      Obx(() => GestureDetector(
                        onTap: () => controller.rememberMe.value = !controller.rememberMe.value,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: (val) => controller.rememberMe.value = val ?? false,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                side: BorderSide(color: AppColors.secondaryText, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],

                    const SizedBox(height: 28),

                    // Submit button
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

                    // OR divider
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

                    // Toggle login/signup
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.toggleMode,
                        child: Text(controller.isLogin.value ? 'Create Account' : 'Back to Login', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )),
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
                    Icon(Icons.security, size: 14, color: AppColors.secondary),
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

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.secondaryText),
      filled: true,
      fillColor: AppColors.isDark ? AppColors.background : AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}