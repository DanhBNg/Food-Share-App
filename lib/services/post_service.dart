import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _postsRef => _firestore.collection('posts');
  CollectionReference get _usersRef => _firestore.collection('users');

  // ================== CREATE POST ==================
  Future<void> createPost({
    required String ingredientName,
    required String quantity,
    required String description,
    required String address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 🔥 LẤY TÊN USER TỪ FIRESTORE (PROFILE)
      final userDoc = await _usersRef.doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      final userName =
          userData?['displayName'] ?? user.email ?? 'Người dùng';

      await _postsRef.add({
        'userId': user.uid,
        'userName': userName,
        'ingredientName': ingredientName,
        'quantity': quantity,
        'address': address,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ================== GET ALL POSTS ==================
  Stream<List<Post>> getAllPosts() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList();
    });
  }

  // ================== GET POST BY ID ==================
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _postsRef.doc(postId).get();
      if (!doc.exists) return null;
      return Post.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  // ================== DELETE POST ==================
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
