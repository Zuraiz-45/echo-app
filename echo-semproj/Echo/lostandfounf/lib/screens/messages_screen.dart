import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.to.currentUser.value;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please sign in again.')));
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: context.theme.appBarTheme.foregroundColor ?? AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: context.theme.dividerColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.search, size: 20, color: context.theme.textTheme.bodyLarge?.color),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: DatabaseService.to.getUserChatsStream(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No private chats yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Open an item detail and start the private conversation between the finder and owner.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere((id) => id != currentUser.id);
              return _buildChatTile(
                context,
                chat: chat,
                currentUserId: currentUser.id,
                otherUserId: otherUserId,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required ChatModel chat,
    required String currentUserId,
    required String otherUserId,
  }) {
    return GestureDetector(
      onTap: () async {
        final results = await Future.wait<dynamic>([
          DatabaseService.to.getUserProfile(otherUserId),
          DatabaseService.to.getItemById(chat.itemId),
        ]);

        final otherUser = results[0] as UserModel?;
        final item = results[1] as ItemModel?;
        if (otherUser == null || item == null) {
          Get.snackbar('Error', 'Chat data is unavailable');
          return;
        }

        Get.to(() => const ChatScreen(), arguments: {
          'chatId': chat.id,
          'otherUser': otherUser,
          'otherUserId': otherUserId,
          'item': item,
          'itemId': item.id,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait<dynamic>([
            DatabaseService.to.getUserProfile(otherUserId),
            DatabaseService.to.getItemById(chat.itemId),
          ]),
          builder: (context, snapshot) {
            final otherUser = snapshot.data != null ? snapshot.data![0] as UserModel? : null;
            final item = snapshot.data != null ? snapshot.data![1] as ItemModel? : null;
            final avatarUrl = otherUser?.profileImageUrl;
            final title = otherUser?.name ?? 'Loading...';
            final subtitle = item?.title ?? 'Item conversation';
            final preview = chat.lastMessage.isEmpty ? 'Open the private chat to start the conversation.' : chat.lastMessage;
            final isLost = item?.type == ItemType.lost;

            return Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  backgroundColor: Colors.grey[300],
                  child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeago.format(chat.lastUpdatedAt, locale: 'en_short'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                              style: TextStyle(
                                color: isLost ? AppColors.lost : AppColors.found,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
