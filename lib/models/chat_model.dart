import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, system }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageBase64;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageBase64,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      imageBase64: map['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'imageBase64': imageBase64,
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
