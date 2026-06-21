import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../widgets/app_image.dart';
import '../widgets/user_posts_list.dart';
import '../controllers/theme_controller.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: context.theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: context.theme.textTheme.bodyLarge?.color),
            onPressed: () {
              ThemeController.to.toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: context.theme.textTheme.bodyLarge?.color),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.to.signOut();
                Get.offAll(() => const AuthScreen());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) {
          return const Center(child: Text('User profile not loaded.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Card
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      await AuthService.to.updateProfileImage(image);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: AppImage(
                          imageData: user.profileImageUrl,
                          isCircular: true,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: context.theme.textTheme.titleLarge?.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text(user.email, style: context.theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('VERIFIED STUDENT', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  if (user.studentId.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.theme.dividerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('ID: ${user.studentId}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.theme.textTheme.bodyLarge?.color)),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Tabs Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                            ],
                          ),
                          child: Center(
                            child: Text('My Reported Items', style: TextStyle(color: context.theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Dynamic Posts List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: UserPostsList(userId: user.id),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
