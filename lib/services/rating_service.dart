import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  final _ref = FirebaseFirestore.instance.collection('ratings');

  Future<void> addRating(Rating rating) async {
    await _ref.add(rating.toMap());
  }

  Stream<List<Rating>> getRatingsOfUser(String userId) {
    return _ref
        .where('targetUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Rating.fromDoc(doc)).toList());
  }
}
