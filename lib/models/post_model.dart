class Post {
  final String id;
  final String userId;
  final String userName;
  final String ingredientName;
  final String quantity;
  final String region;
  final String description;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.ingredientName,
    required this.quantity,
    required this.region,
    required this.description,
    required this.createdAt,
  });

  // Chuyển đổi từ JSON sang model
  factory Post.fromMap(Map<dynamic, dynamic> map, String docId) {
    return Post(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Ẩn danh',
      ingredientName: map['ingredientName'] ?? '',
      quantity: map['quantity'] ?? '',
      region: map['region'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Chuyển đổi từ model sang JSON
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'region': region,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
