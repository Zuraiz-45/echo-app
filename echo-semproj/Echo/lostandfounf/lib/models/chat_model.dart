import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatModel {
  final String id;
  final List<String> participants;
  final String itemId;
  final String lastMessage;
  final DateTime lastUpdatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.itemId,
    required this.lastMessage,
    required this.lastUpdatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      itemId: map['itemId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastUpdatedAt: (map['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'itemId': itemId,
      'lastMessage': lastMessage,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }
}
