import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class MessagesController extends GetxController {
  final RxList<ChatModel> chats = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final currentUser = AuthService.to.currentUser.value;
    if (currentUser != null) {
      chats.bindStream(DatabaseService.to.getUserChatsStream(currentUser.id));
    }
  }
}
