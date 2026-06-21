import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for Web fix
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/colors.dart';
import '../controllers/add_item_controller.dart';
import '../services/auth_service.dart';
import '../widgets/app_image.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Report Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          Obx(() {
            final user = AuthService.to.currentUser.value;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8),
              child: Center(
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: user?.profileImageUrl != null
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
                  child: user?.profileImageUrl == null
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleType(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: controller.isLost.value ? AppColors.lost : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: controller.isLost.value ? [BoxShadow(color: AppColors.lost.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                        ),
                        child: Center(
                          child: Text(
                            'I Lost Something',
                            style: TextStyle(
                              color: controller.isLost.value ? Colors.white : AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleType(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !controller.isLost.value ? AppColors.found : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: !controller.isLost.value ? [BoxShadow(color: AppColors.found.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                        ),
                        child: Center(
                          child: Text(
                            'I Found Something',
                            style: TextStyle(
                              color: !controller.isLost.value ? Colors.white : AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (!controller.isLost.value) ...[
               const SizedBox(height: 32),
               Center(
                 child: Text('NEW SUBMISSION', style: TextStyle(color: AppColors.found, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
               ),
               const SizedBox(height: 8),
               Center(
                 child: Text('Register a\nRecovery.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 32, height: 1.1)),
               ),
               const SizedBox(height: 12),
               Center(
                 child: Text('Help the community by providing accurate\ndetails about the item you\'ve located on\ncampus.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
               )
            ],

            const SizedBox(height: 32),
            _buildLabel(controller.isLost.value ? 'PHOTO EVIDENCE' : 'ITEM PHOTO'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      child: controller.imagePath.value != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: controller.selectedImageFile != null
                                ? (kIsWeb 
                                    ? Image.network(controller.imagePath.value!, fit: BoxFit.cover)
                                    : Image.file(File(controller.imagePath.value!), fit: BoxFit.cover))
                                : AppImage(
                                    imageData: controller.imagePath.value!,
                                    fit: BoxFit.cover,
                                    borderRadius: 20,
                                  ),
                          )
                        : null,
                    ),
                    if (controller.imagePath.value == null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.camera_alt, size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            Text('Tap to upload item photo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('JPEG, PNG up to 10MB', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildLabel('ITEM NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              style: TextStyle(color: AppColors.text, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'e.g. Blue North Face Backpack',
                hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 15),
                filled: true,
                fillColor: AppColors.isDark ? AppColors.surface : AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildLabel('CATEGORY'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.selectedCategory.value,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.isDark ? AppColors.surface : AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 15, color: AppColors.text)))).toList(),
              onChanged: (v) {
                if (v != null) controller.selectedCategory.value = v;
              },
            ),
            
            const SizedBox(height: 24),
            _buildLabel(controller.isLost.value ? 'LAST SEEN AT' : 'FOUND AT'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.locationController,
              style: TextStyle(color: AppColors.text, fontSize: 15),
              decoration: InputDecoration(
                hintText: controller.isLost.value ? 'e.g. Main Library' : 'e.g. Student Cafeteria',
                hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 15),
                prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.isDark ? AppColors.surface : AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              style: TextStyle(color: AppColors.text, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Mention specific details like stickers, scratches, or contents inside...',
                hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 15),
                filled: true,
                fillColor: AppColors.isDark ? AppColors.surface : AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.isSubmitting.value ? null : controller.submit,
                child: controller.isSubmitting.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Submit Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 12),
                    Icon(Icons.send, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'By submitting, you agree that the provided information is accurate to your best knowledge.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        )),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5));
  }
}