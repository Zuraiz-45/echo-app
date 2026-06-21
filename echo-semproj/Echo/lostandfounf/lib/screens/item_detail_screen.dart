import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/colors.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null || Get.arguments is! ItemModel) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }
    
    final ItemModel item = Get.arguments as ItemModel;
    final bool isLost = item.type == ItemType.lost;
    final currentUser = AuthService.to.currentUser.value;
    final bool isOwner = currentUser?.id == item.ownerId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            actions: [
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                      onSelected: (val) async {
                        if (val == 'resolve') {
                          await DatabaseService.to.updateItemStatus(item.id, ItemStatus.resolved);
                          Get.back();
                          Get.snackbar('Success', 'Item marked as resolved');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'resolve', child: Text('Mark as Resolved'))
                      ],
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrls.isNotEmpty
                  ? Image.network(item.imageUrls.first, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isLost ? AppColors.lost : AppColors.found).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLost ? 'LOST ITEM' : 'FOUND ITEM',
                          style: TextStyle(color: isLost ? AppColors.lost : AppColors.found, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ),
                      Text(timeago.format(item.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2)),
                  const SizedBox(height: 24),
                  
                  // Detail Row 1
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isLost ? 'Last Seen At' : 'Found At', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.location, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Detail Row 2
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.category, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.category, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Color(0xFFE2E8F0)),
                  ),
                  
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // User info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FutureBuilder(
                              future: DatabaseService.to.getUserProfile(item.ownerId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircleAvatar(radius: 20, backgroundColor: Colors.grey);
                                }
                                final pUser = snapshot.data;
                                return CircleAvatar(
                                  radius: 20,
                                  backgroundImage: pUser?.profileImageUrl != null ? NetworkImage(pUser!.profileImageUrl!) : null,
                                  backgroundColor: Colors.grey[300],
                                  child: pUser?.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                                );
                              }
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reported by', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                FutureBuilder(
                                  future: DatabaseService.to.getUserProfile(item.ownerId),
                                  builder: (context, snapshot) {
                                    return Text(snapshot.data?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14));
                                  }
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: isOwner 
        ? null 
        : Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -10))
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (currentUser == null) return;
                    
                    // Start or enter chat
                    final chatId = await DatabaseService.to.getOrCreateChat(
                      currentUser.id, 
                      item.ownerId, 
                      item.id
                    );
                    
                    final targetUser = await DatabaseService.to.getUserProfile(item.ownerId);
                    
                    Get.to(() => const ChatScreen(), arguments: {
                      'chatId': chatId,
                      'otherUser': targetUser,
                      'item': item,
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLost ? "I found this" : "This is mine", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
