import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String ingredientName;
  final String quantity;
  final String address;
  final String description;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.ingredientName,
    required this.quantity,
    required this.address,
    required this.description,
    required this.createdAt,
  });

  // // Chuyển đổi từ JSON sang model
  // factory Post.fromMap(Map<dynamic, dynamic> map, String docId) {
  //   return Post(
  //     id: docId,
  //     userId: map['userId'] ?? '',
  //     userName: map['userName'] ?? 'Ẩn danh',
  //     ingredientName: map['ingredientName'] ?? '',
  //     quantity: map['quantity'] ?? '',
  //     address: map['address'] ?? '',
  //     description: map['description'] ?? '',
  //     createdAt: map['createdAt'] != null
  //         ? DateTime.parse(map['createdAt'])
  //         : DateTime.now(),
  //   );
  // }

  // Chuyển đổi từ model sang JSON
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'address': address,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      ingredientName: data['ingredientName'],
      quantity: data['quantity'],
      address: data['address'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}



