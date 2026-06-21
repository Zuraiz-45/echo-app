import 'package:get/get.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';

class HomeController extends GetxController {
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxString selectedFilter = 'All Items'.obs;

  @override
  void onInit() {
    super.onInit();
    items.bindStream(DatabaseService.to.getItemsStream());
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<ItemModel> get filteredItems {
    if (selectedFilter.value == 'All Items') {
      return items;
    } else if (selectedFilter.value == 'Lost') {
      return items.where((item) => item.type == ItemType.lost).toList();
    } else if (selectedFilter.value == 'Found') {
      return items.where((item) => item.type == ItemType.found).toList();
    } else {
      // Category filtering
      return items.where((item) => item.category == selectedFilter.value).toList();
    }
  }
}
