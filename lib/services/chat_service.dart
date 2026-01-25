import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatService {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String getChatId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }

  Future<void> sendMessage({
    required String receiverId,
    String? text,
    String? imageUrl,
  }) async {
    final senderId = _auth.currentUser!.uid;
    final chatId = getChatId(senderId, receiverId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final messageRef = _db.child('messages/$chatId').push();

    await messageRef.set({
      'senderId': senderId,
      'text': text ?? '',
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'seen': false,
    });

    await _db.child('userChats/$senderId/$chatId').set({
      'otherUserId': receiverId,
      'lastMessage': text ?? '📷 Ảnh',
      'timestamp': timestamp,
      'unread': false,
    });

    await _db.child('userChats/$receiverId/$chatId').set({
      'otherUserId': senderId,
      'lastMessage': text ?? '📷 Ảnh',
      'timestamp': timestamp,
      'unread': true,
    });
  }

  Future<void> markAsSeen(String chatId) async {
    final uid = _auth.currentUser!.uid;

    await _db.child('userChats/$uid/$chatId/unread').set(false);

    final snapshot = await _db.child('messages/$chatId').get();
    for (final msg in snapshot.children) {
      if (msg.child('senderId').value != uid) {
        msg.ref.child('seen').set(true);
      }
    }
  }
}
