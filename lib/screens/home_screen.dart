import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/colors.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import '../widgets/app_image.dart';
import '../controllers/home_controller.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/item_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
        ),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              controller: controller.searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search title or description...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                controller.searchQuery.value = val;
              },
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Echo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
              Text('Lost and Found', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
            ],
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.white),
                  onPressed: () {
                    controller.isSearching.value = false;
                    controller.searchQuery.value = '';
                    controller.searchController.clear();
                  },
                ),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, size: 20, color: Colors.white),
                onPressed: () {
                  controller.isSearching.value = true;
                },
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campus Feed', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 6),
                Text(
                  "Find what you've lost, return what you've found.", 
                  style: TextStyle(fontSize: 15, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => Row(
              children: [
                _buildFilterChip('All Items', controller.selectedFilter.value == 'All Items', controller),
                _buildFilterChip('Lost', controller.selectedFilter.value == 'Lost', controller),
                _buildFilterChip('Found', controller.selectedFilter.value == 'Found', controller),
                _buildFilterChip('Electronics', controller.selectedFilter.value == 'Electronics', controller),
                _buildFilterChip('Cards/IDs', controller.selectedFilter.value == 'Cards/IDs', controller),
              ],
            )),
          ),
          const SizedBox(height: 12),
          // Feed
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;
              if (items.isEmpty) {
                return Center(child: Text('No items found.', style: TextStyle(color: AppColors.secondaryText)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildItemCard(
                    context,
                    item: item,
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => Get.to(() => const AddItemScreen()),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, HomeController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => controller.setFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: AppColors.border),
            boxShadow: isSelected ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(AppColors.isDark ? 0.2 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, {
    required ItemModel item,
  }) {
    final bool isLost = item.type == ItemType.lost;
    final String time = timeago.format(item.createdAt, locale: 'en_short');
    
    return GestureDetector(
      onTap: () => Get.to(() => const ItemDetailScreen(), arguments: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: isLost ? AppColors.lost : AppColors.found, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(AppColors.isDark ? 0.2 : 0.04), 
              blurRadius: 16, 
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(0), topLeft: Radius.circular(0)),
                  child: AppImage(
                    imageData: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLost ? AppColors.lost : AppColors.found,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLost ? 'LOST' : 'FOUND',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text(time, style: TextStyle(color: AppColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Text(item.location, style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 12, backgroundColor: AppColors.secondaryText.withOpacity(0.2), child: Icon(Icons.person, size: 12, color: AppColors.secondaryText)),
                          const SizedBox(width: 10),
                          FutureBuilder(
                            future: DatabaseService.to.getUserProfile(item.ownerId),
                            builder: (context, snapshot) {
                              final user = snapshot.data as dynamic;
                              final name = snapshot.hasData && user != null ? user.name as String : 'Loading...';
                              return Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.text));
                            }
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            isLost ? 'Details' : 'Claim',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Icon(isLost ? Icons.arrow_forward : Icons.check_circle, size: 16, color: AppColors.primary),
                        ]
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
