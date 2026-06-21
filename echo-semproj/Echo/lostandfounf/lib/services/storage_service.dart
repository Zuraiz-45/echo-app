import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static StorageService get to => Get.find();

  Future<String?> uploadItemImage(File file, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('items/$userId/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(File file, String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
