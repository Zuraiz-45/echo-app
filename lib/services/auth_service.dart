import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static AuthService get to => Get.find();

  // Observable currentUser that updates dynamically when auth state changes
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Bind to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        currentUser.value = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Fallback if profile doesn't exist
        currentUser.value = UserModel(
          id: uid,
          email: '',
          name: 'Student',
          studentId: '',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Register a new user with email, password, name, and studentId
  /// Saves user profile to Firestore with uid, name, email, studentId, and createdAt
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String studentId,
  }) async {
    try {
      // Create user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        Get.snackbar(
          'Registration Failed',
          'Unable to create user account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      // Create user model with all required fields
      final newUser = UserModel(
        id: user.uid,
        name: name,
        email: email,
        studentId: studentId,
        createdAt: DateTime.now(),
      );

      // Save user profile to Firestore
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      // Update current user observable
      currentUser.value = newUser;

      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }

      Get.snackbar(
        'Registration Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Login user with email and password
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        Get.snackbar(
          'Login Failed',
          'Unable to sign in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      // Load user profile from Firestore
      await _loadUserProfile(user.uid);

      Get.snackbar(
        'Welcome Back',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found for this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      Get.snackbar(
        'Login Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Sign out the current user
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign Out Error',
        e.message ?? 'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Sign Out Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Upload a profile image as Base64 with a size check
  Future<bool> updateProfileImage(XFile imageFile) async {
    try {
      // Size check (700 KB Limit)
      int fileSizeInBytes = await imageFile.length();
      if (fileSizeInBytes > 700 * 1024) {
        Get.snackbar(
          'Size Limit Exceeded',
          'Image is too large! Please upload an image under 700 KB.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      // Read Bytes and encode to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final uid = currentUser.value?.id;
      if (uid == null) return false;

      // Update in Firestore
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': base64Image,
      });

      // Update local reactive user state
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        email: currentUser.value!.email,
        studentId: currentUser.value!.studentId,
        profileImageUrl: base64Image,
        createdAt: currentUser.value!.createdAt,
      );

      Get.snackbar(
        'Success',
        'Profile photo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Get current Firebase user (for internal use)
  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => firebaseUser != null;
}