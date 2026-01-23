import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String ingredientName;
  final String ingredientNameLower;
  final String quantity;
  final String address;
  final String description;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.ingredientName,
    required this.ingredientNameLower,
    required this.quantity,
    required this.address,
    required this.description,
    required this.createdAt,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Ẩn danh',
      ingredientName: data['ingredientName'] ?? '',
      ingredientNameLower: data['ingredientNameLower'] ?? '',
      quantity: data['quantity'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'ingredientName': ingredientName,
      'ingredientNameLower': ingredientName.toLowerCase(),
      'quantity': quantity,
      'address': address,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
