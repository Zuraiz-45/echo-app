import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/chat_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';
import '../widgets/app_image.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  String chatId = '';
  String currentUserId = '';
  String? otherUserId;
  String? itemId;
  UserModel? otherUser;
  ItemModel? item;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    chatId = args?['chatId'] as String? ?? '';
    currentUserId = AuthService.to.currentUser.value?.id ?? '';
    otherUser = args?['otherUser'] as UserModel?;
    item = args?['item'] as ItemModel?;
    otherUserId = args?['otherUserId'] as String?;
    itemId = args?['itemId'] as String?;
    _loadContext();
  }

  Future<void> _loadContext() async {
    if (chatId.isEmpty || currentUserId.isEmpty) {
      errorMessage.value = 'Unable to open this chat.';
      isLoading.value = false;
      return;
    }

    final chat = await DatabaseService.to.getChatById(chatId);
    if (chat == null || !chat.participants.contains(currentUserId)) {
      errorMessage.value = 'You do not have access to this chat.';
      isLoading.value = false;
      return;
    }

    otherUserId ??= chat.participants.firstWhere((id) => id != currentUserId);
    itemId ??= chat.itemId;

    otherUser ??= await DatabaseService.to.getUserProfile(otherUserId!);
    item ??= await DatabaseService.to.getItemById(itemId!);

    if (otherUser == null || item == null) {
      errorMessage.value = 'Chat details are unavailable.';
      isLoading.value = false;
      return;
    }

    messages.bindStream(DatabaseService.to.getChatMessagesStream(chatId));
    isLoading.value = false;
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final text = messageController.text.trim();
    messageController.clear();

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    DatabaseService.to.sendMessage(chatId, message);
  }

  Future<void> sendImageMessage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      // 1. Size check (700 KB Limit)
      int fileSizeInBytes = await image.length();
      if (fileSizeInBytes > 700 * 1024) {
        Get.snackbar(
          'Size Limit Exceeded',
          'Image is too large! Please select an image under 700 KB.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // 2. Read bytes and encode to Base64
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 3. Build & send MessageModel
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        text: 'Sent an image',
        timestamp: DateTime.now(),
        type: MessageType.image,
        imageBase64: base64Image,
      );

      await DatabaseService.to.sendMessage(chatId, message);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (controller.errorMessage.value.isNotEmpty || controller.otherUser == null || controller.item == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : 'Chat data is unavailable.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text),
              ),
            ),
          ),
        );
      }

      final item = controller.item!;
      final otherUser = controller.otherUser!;
      final bool isLost = item.type == ItemType.lost;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: otherUser.profileImageUrl != null ? NetworkImage(otherUser.profileImageUrl!) : null,
                backgroundColor: AppColors.secondaryText.withOpacity(0.2),
                child: otherUser.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherUser.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Private chat', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                ],
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.border,
                      image: item.imageUrls.isNotEmpty
                          ? DecorationImage(image: NetworkImage(item.imageUrls.first), fit: BoxFit.cover)
                          : null,
                    ),
                    child: item.imageUrls.isEmpty ? Icon(Icons.image, color: AppColors.secondaryText) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isLost ? AppColors.lost : AppColors.found).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isLost ? 'LOST' : 'FOUND',
                                style: TextStyle(color: isLost ? AppColors.lost : AppColors.found, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(child: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Reported ${timeago.format(item.createdAt)}', style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No messages yet. Send the first private message between the finder and owner.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final isMe = message.senderId == controller.currentUserId;
                    return _buildMessageBubble(
                      message,
                      isMe,
                      timeago.format(message.timestamp, locale: 'en_short'),
                    );
                  },
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(AppColors.isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(Icons.add, color: AppColors.primary),
                        onPressed: controller.sendImageMessage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        style: TextStyle(color: AppColors.text, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 15),
                          filled: true,
                          fillColor: AppColors.isDark ? AppColors.background : AppColors.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: controller.sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, String time) {
    final bool isImage = message.type == MessageType.image;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12, 
              backgroundColor: AppColors.secondaryText.withOpacity(0.2), 
              child: Icon(Icons.person, size: 12, color: AppColors.secondaryText)
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: isImage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: isImage
                  ? null
                  : BoxDecoration(
                      color: isMe
                          ? AppColors.primary
                          : (AppColors.isDark ? AppColors.dividerDarkColor : AppColors.lightGrey),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                      ),
                      border: isMe ? null : Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                      ),
                      child: AppImage(
                        imageData: message.imageBase64,
                        width: 220,
                        height: 160,
                        fit: BoxFit.cover,
                        borderRadius: 0,
                      ),
                    )
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : (AppColors.isDark ? Colors.white : AppColors.darkSlate),
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Text(time, style: TextStyle(color: AppColors.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }
}
