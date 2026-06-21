// This controller has been replaced by GlobalChatController in messages_screen.dart
// Kept for backward compatibility with any remaining references.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class MessagesController extends GetxController {
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxMap<String, String> userNames = <String, String>{}.obs;
  
  final RxString searchQuery = ''.obs;
  final searchController = TextEditingController();
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    final currentUser = AuthService.to.currentUser.value;
    if (currentUser != null) {
      chats.bindStream(DatabaseService.to.getUserChatsStream(currentUser.id));
    }
  }

  List<ChatModel> get filteredChats {
    return chats;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
