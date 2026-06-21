import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';
import '../widgets/app_image.dart';
import '../screens/add_item_screen.dart';

class UserPostsList extends StatelessWidget {
  final String userId;

  const UserPostsList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ItemModel>>(
      stream: DatabaseService.to.getUserItemsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No posts found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your reported items will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildPostCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildPostCard(BuildContext context, ItemModel item) {
    final bool isLost = item.type == ItemType.lost;
    final bool isResolved = item.status == ItemStatus.resolved;
    final String dateStr = timeago.format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isResolved
                ? AppColors.resolved
                : (isLost ? AppColors.lost : AppColors.found),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppColors.isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppImage(
              imageData: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              borderRadius: 12,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, right: 12.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isResolved
                            ? 'RESOLVED'
                            : (isLost ? 'LOST ITEM' : 'FOUND ITEM'),
                        style: TextStyle(
                          color: isResolved
                              ? AppColors.resolved
                              : (isLost ? AppColors.lost : AppColors.found),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: context.theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isResolved ? AppColors.resolved.withOpacity(0.5) : AppColors.found,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          icon: Icon(
                            isResolved ? Icons.handshake : Icons.check_circle,
                            color: isResolved && !AppColors.isDark ? AppColors.darkSlate : Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            isResolved ? 'Resolved' : 'Mark as Resolved',
                            style: TextStyle(
                              color: isResolved && !AppColors.isDark ? AppColors.darkSlate : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: isResolved
                              ? null
                              : () async {
                                  await DatabaseService.to.updateItemStatus(item.id, ItemStatus.resolved);
                                  Get.snackbar(
                                    'Success',
                                    'Item marked as resolved',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.primary,
                                    colorText: Colors.white,
                                  );
                                },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.to(() => const AddItemScreen(), arguments: item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
