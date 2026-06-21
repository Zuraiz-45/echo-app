import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';

class HomeController extends GetxController {
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxString selectedFilter = 'All Items'.obs;
  
  final RxString searchQuery = ''.obs;
  final searchController = TextEditingController();
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    items.bindStream(DatabaseService.to.getItemsStream());
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<ItemModel> get filteredItems {
    List<ItemModel> list = items;
    if (selectedFilter.value == 'Lost') {
      list = items.where((item) => item.type == ItemType.lost).toList();
    } else if (selectedFilter.value == 'Found') {
      list = items.where((item) => item.type == ItemType.found).toList();
    } else if (selectedFilter.value != 'All Items') {
      list = items.where((item) => item.category == selectedFilter.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
