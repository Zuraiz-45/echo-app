import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/chat_model.dart';

class DatabaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static DatabaseService get to => Get.find();

  // ----- Users -----
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ----- Items -----
  Future<void> addItem(ItemModel item) async {
    await _firestore.collection('items').doc(item.id).set(item.toMap());
  }
  
  Future<void> updateItemStatus(String itemId, ItemStatus status) async {
    await _firestore.collection('items').doc(itemId).update({'status': status.name});
  }

  Future<ItemModel?> getItemById(String itemId) async {
    final doc = await _firestore.collection('items').doc(itemId).get();
    if (doc.exists && doc.data() != null) {
      return ItemModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<ItemModel>> getItemsStream() {
    return _firestore.collection('items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<ItemModel>> getUserItemsStream(String userId) {
    return _firestore.collection('items')
      .where('ownerId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
          .toList();
        // Sort client-side to avoid needing a composite index
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
  }

  // ----- Chats -----
  Future<String> getOrCreateChat(String currentUserId, String otherUserId, String itemId) async {
    final participants = [currentUserId, otherUserId]..sort();
    final chatId = '${itemId}_${participants[0]}_${participants[1]}';
    final chatRef = _firestore.collection('chats').doc(chatId);
    final snapshot = await chatRef.get();

    if (snapshot.exists) {
      return chatId;
    }

    final newChat = ChatModel(
      id: chatId,
      participants: participants,
      itemId: itemId,
      lastMessage: '',
      lastUpdatedAt: DateTime.now(),
    );
    await chatRef.set(newChat.toMap());
    return chatId;
  }

  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (doc.exists && doc.data() != null) {
      return ChatModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore.collection('chats')
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snapshot) {
        final chats = snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
          .toList();
        chats.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
        return chats;
      });
  }

  // ----- Messages -----
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(message.id).set(message.toMap());
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // ----- Global Group Chat -----
  Stream<List<MessageModel>> getGlobalChatStream() {
    return _firestore.collection('global_chat')
      .orderBy('timestamp', descending: true)
      .limit(200)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> sendGlobalMessage(MessageModel message) async {
    await _firestore.collection('global_chat').doc(message.id).set(message.toMap());
  }
}
