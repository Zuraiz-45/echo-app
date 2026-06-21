import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';

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
    );

    DatabaseService.to.sendMessage(chatId, message);
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : 'Chat data is unavailable.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      final item = controller.item!;
      final otherUser = controller.otherUser!;
      final bool isLost = item.type == ItemType.lost;

      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: otherUser.profileImageUrl != null ? NetworkImage(otherUser.profileImageUrl!) : null,
                backgroundColor: Colors.grey[300],
                child: otherUser.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherUser.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('Private chat', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!), bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: item.imageUrls.isNotEmpty
                          ? DecorationImage(image: NetworkImage(item.imageUrls.first), fit: BoxFit.cover)
                          : null,
                    ),
                    child: item.imageUrls.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
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
                            Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Reported ${timeago.format(item.createdAt)}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
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
                        style: TextStyle(color: Colors.grey[600]),
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
                      message.text,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 12, color: Colors.white)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                ),
                border: isMe ? null : Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }
}
