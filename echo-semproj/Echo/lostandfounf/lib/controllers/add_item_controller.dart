import 'dart:io';
import 'dart:convert'; // Added for Base64 Encode
import 'package:flutter/foundation.dart' show kIsWeb; // Added for platform check
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
// import '../services/storage_service.dart'; // STORAGE BYPASSED: Commented out

import '../services/auth_service.dart';

class AddItemController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  
  final isLost = true.obs;
  final selectedCategory = 'Other'.obs;
  final categories = ['Electronics', 'Cards/IDs', 'Books, Notes & Stationery', 'Keys', 'Clothing & Accessories', 'Other'];
  
  final imagePath = Rx<String?>(null);
  XFile? _selectedImageFile; // Added to securely hold the file data for bytes reading

  final isSubmitting = false.obs;

  void toggleType(bool lost) {
    isLost.value = lost;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImageFile = image; // Save the actual file object
      imagePath.value = image.path; // Update UI path
    }
  }

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty || locationController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide a title and location', 
          backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    final currentUser = AuthService.to.currentUser.value;
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to post', 
          backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    isSubmitting.value = true;
    try {
      String? base64ImageUrl;

      // --- BASE64 & 700 KB LIMIT LOGIC ---
      if (_selectedImageFile != null) {
        
        // 1. Check Image Size (700 KB Limit)
        int fileSizeInBytes = await _selectedImageFile!.length();
        if (fileSizeInBytes > 700 * 1024) { 
          Get.snackbar(
            'Size Limit Exceeded', 
            'Image is too large! Please upload an image under 700 KB.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
          isSubmitting.value = false;
          return; // Stop the upload process immediately
        }

        // 2. Read Bytes (Works safely on both Web and Mobile)
        List<int> imageBytes = await _selectedImageFile!.readAsBytes();
        
        // 3. Encode to Base64 String
        base64ImageUrl = base64Encode(imageBytes);
      }
      // ------------------------------------

      final docRef = FirebaseFirestore.instance.collection('items').doc();
      
      final newItem = ItemModel(
        id: docRef.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        // Save the massive Base64 string directly into the array instead of a URL
        imageUrls: base64ImageUrl != null ? [base64ImageUrl] : [], 
        ownerId: currentUser.id,
        createdAt: DateTime.now(),
        status: isLost.value ? ItemStatus.lost : ItemStatus.found,
        type: isLost.value ? ItemType.lost : ItemType.found,
        category: selectedCategory.value,
      );

      await DatabaseService.to.addItem(newItem);
      
      Get.back();
      Get.snackbar(
        'Success', 
        'Item reported successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to submit report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}