import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus { lost, found, resolved }
enum ItemType { lost, found }

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime createdAt;
  final ItemStatus status;
  final ItemType type;
  final String category;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrls,
    required this.ownerId,
    required this.createdAt,
    required this.status,
    required this.type,
    required this.category,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ItemModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'lost'),
        orElse: () => ItemStatus.lost,
      ),
      type: ItemType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'lost'),
        orElse: () => ItemType.lost,
      ),
      category: map['category'] ?? 'Other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'type': type.name,
      'category': category,
    };
  }
}
