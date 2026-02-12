import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String targetUserId;
  final String fromUserId;
  final String fromName;
  final String fromPhoto;
  final String type;
  final String content;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.targetUserId,
    required this.fromUserId,
    required this.fromName,
    required this.fromPhoto,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  factory Rating.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Rating(
      id: doc.id,
      targetUserId: data['targetUserId']?.toString() ?? '',
      fromUserId: data['fromUserId']?.toString() ?? '',
      fromName: data['fromName']?.toString() ?? 'Ẩn danh',
      fromPhoto: data['fromPhoto']?.toString() ?? '',
      type: data['type']?.toString() ?? 'Tốt',
      content: data['content']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate()
          ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetUserId': targetUserId,
      'fromUserId': fromUserId,
      'fromName': fromName,
      'fromPhoto': fromPhoto,
      'type': type,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
