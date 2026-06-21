import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';

class GlobalChatController extends GetxController {
  final messageController = TextEditingController();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final ScrollController scrollController = ScrollController();

  // Cache for user profiles so we don't refetch for every message
  final RxMap<String, UserModel> userCache = <String, UserModel>{}.obs;

  String get currentUserId => AuthService.to.currentUser.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  void _loadMessages() {
    messages.bindStream(DatabaseService.to.getGlobalChatStream());
    isLoading.value = false;

    // Resolve user profiles whenever message list changes
    ever(messages, (List<MessageModel> msgList) {
      for (final msg in msgList) {
        if (!userCache.containsKey(msg.senderId)) {
          _fetchUser(msg.senderId);
        }
      }
    });
  }

  Future<void> _fetchUser(String userId) async {
    try {
      final profile = await DatabaseService.to.getUserProfile(userId);
      if (profile != null) {
        userCache[userId] = profile;
      }
    } catch (_) {}
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    DatabaseService.to.sendGlobalMessage(message);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GlobalChatController());
    final currentUser = AuthService.to.currentUser.value;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please sign in again.')));
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Chat',
                  style: TextStyle(
                    color: context.theme.appBarTheme.foregroundColor ?? Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'All campus members',
                  style: TextStyle(
                    color: (context.theme.appBarTheme.foregroundColor ?? Colors.white).withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to say something in the community chat!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.senderId == controller.currentUserId;

                  // Check if we should show the sender name (first msg or different sender from previous)
                  bool showSenderName = !isMe;
                  if (!isMe && index < controller.messages.length - 1) {
                    final prevMsg = controller.messages[index + 1]; // reversed list
                    if (prevMsg.senderId == message.senderId) {
                      showSenderName = false;
                    }
                  }

                  return _buildMessageBubble(
                    context,
                    message: message,
                    isMe: isMe,
                    showSenderName: showSenderName,
                    controller: controller,
                  );
                },
              );
            }),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    context.theme.brightness == Brightness.dark ? 0.2 : 0.03,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: TextStyle(
                        color: context.theme.textTheme.bodyLarge?.color,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: context.theme.brightness == Brightness.dark
                            ? context.theme.scaffoldBackgroundColor
                            : AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, {
    required MessageModel message,
    required bool isMe,
    required bool showSenderName,
    required GlobalChatController controller,
  }) {
    final isDark = context.theme.brightness == Brightness.dark;
    final time = timeago.format(message.timestamp, locale: 'en_short');

    // Get sender info from cache
    final sender = controller.userCache[message.senderId];
    final senderName = sender?.name ?? 'Student';

    // Assign a consistent color to each sender based on their ID hash
    final senderColor = _getSenderColor(message.senderId);

    return Padding(
      padding: EdgeInsets.only(bottom: showSenderName ? 12 : 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showSenderName)
              CircleAvatar(
                radius: 14,
                backgroundColor: senderColor.withOpacity(0.2),
                child: Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: senderColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(width: 28), // placeholder to keep alignment
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSenderName && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        color: senderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? context.theme.colorScheme.primary
                        : (isDark ? AppColors.dividerDark : AppColors.lightGrey),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: context.theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.darkSlate),
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.6)
                              : context.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Generate a consistent color for each sender based on their userId
  Color _getSenderColor(String userId) {
    final colors = [
      const Color(0xFF2563EB), // blue
      const Color(0xFF7C3AED), // purple
      const Color(0xFF059669), // green
      const Color(0xFFD97706), // amber
      const Color(0xFFDC2626), // red
      const Color(0xFF0891B2), // cyan
      const Color(0xFFDB2777), // pink
      const Color(0xFF4F46E5), // indigo
    ];
    final hash = userId.hashCode.abs();
    return colors[hash % colors.length];
  }
}
