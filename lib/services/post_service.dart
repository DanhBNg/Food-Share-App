import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference đến nhánh posts trong Firebase
  DatabaseReference get _postsRef => _database.ref('posts');

  // Tạo bài đăng mới
  Future<void> createPost({
    required String ingredientName,
    required String quantity,
    required String region,
    required String description,
    required String userName,
  }) async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      
      final post = Post(
        id: '', // Firebase sẽ tự động tạo id
        userId: userId,
        userName: userName,
        ingredientName: ingredientName,
        quantity: quantity,
        region: region,
        description: description,
        createdAt: DateTime.now(),
      );

      await _postsRef.push().set(post.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách bài đăng theo tỉnh/khu vực
  Stream<List<Post>> getPostsByRegion(String region) {
    if (region.isEmpty) {
      // Nếu không chọn tỉnh, hiển thị tất cả bài đăng
      return _postsRef
          .orderByChild('createdAt')
          .onValue
          .map((event) {
            final posts = <Post>[];
            if (event.snapshot.exists) {
              final Map<dynamic, dynamic> values =
                  event.snapshot.value as Map<dynamic, dynamic>;
              values.forEach((key, value) {
                posts.add(Post.fromMap(value, key));
              });
            }
            // Sắp xếp từ mới nhất đến cũ nhất
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return posts;
          });
    } else {
      // Lọc theo khu vực
      return _postsRef.onValue.map((event) {
        final posts = <Post>[];
        if (event.snapshot.exists) {
          final Map<dynamic, dynamic> values =
              event.snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            if (value['region'] == region) {
              posts.add(Post.fromMap(value, key));
            }
          });
        }
        // Sắp xếp từ mới nhất đến cũ nhất
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      });
    }
  }

  // Lấy thông tin một bài đăng
  Future<Post?> getPostById(String postId) async {
    try {
      final snapshot = await _postsRef.child(postId).get();
      if (snapshot.exists) {
        return Post.fromMap(snapshot.value as Map<dynamic, dynamic>, postId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Xóa bài đăng
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.child(postId).remove();
    } catch (e) {
      rethrow;
    }
  }
}
