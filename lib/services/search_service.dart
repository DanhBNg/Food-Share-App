import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search KHÔNG phân biệt hoa thường
  /// Chỉ search trong các post đang có
  Future<List<Post>> searchPosts(String keyword) async {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) return [];

    // LẤY TẤT CẢ POST (Firestore KHÔNG hỗ trợ contains text)
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    final results = snapshot.docs.where((doc) {
      final data = doc.data();
      final ingredientName =
      (data['ingredientName'] ?? '').toString().toLowerCase();

      return ingredientName.contains(query);
    }).map((doc) {
      return Post.fromFirestore(doc);
    }).toList();

    return results;
  }
}
