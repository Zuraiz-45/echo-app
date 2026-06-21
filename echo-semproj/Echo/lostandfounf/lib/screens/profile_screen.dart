import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/colors.dart';

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
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          IconButton(icon: Icon(Icons.settings, color: context.theme.textTheme.bodyLarge?.color), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Card
            const Center(
              child: Stack(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
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
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Ahmed Khan', style: context.theme.textTheme.titleLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text('ahmed.khan@student.comsats.edu.pk', style: context.theme.textTheme.bodyMedium),
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
                  child: const Text('VERIFIED STUDENT', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.theme.dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ID: FA21-BCS-084', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.theme.textTheme.bodyLarge?.color)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Tabs
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
                          child: Text('Active Posts', style: TextStyle(color: context.theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text('Resolved History', style: context.theme.textTheme.bodyMedium),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Posts List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPostCard(
                    context,
                    title: 'Black Leather Wallet',
                    date: 'Oct 24, 2023',
                    desc: 'Lost near the Main Library cafeteria around 2:00 PM...',
                    isLost: true,
                    imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',
                  ),
                  _buildPostCard(
                    context,
                    title: 'MacBook Charger',
                    date: 'Oct 22, 2023',
                    desc: 'Found at CS Department Room 04. 61W USB-C...',
                    isLost: false,
                    imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36340cf0?w=500',
                    resolvedText: 'Returned to Owner',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, {
    required String title,
    required String date,
    required String desc,
    required bool isLost,
    required String imageUrl,
    String? resolvedText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: isLost ? AppColors.lost : AppColors.found, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, right: 12.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isLost ? 'LOST ITEM' : 'FOUND ITEM', style: TextStyle(color: isLost ? AppColors.lost : AppColors.found, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(date, style: context.theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: context.theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: context.theme.textTheme.bodyMedium?.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.found,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: Icon(resolvedText != null ? Icons.handshake : Icons.check_circle, color: Colors.white, size: 16),
                          label: Text(resolvedText ?? 'Mark as Found', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit, size: 16, color: context.theme.textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
