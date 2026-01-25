import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_room.dart';

class ChatService {
  static final _auth = FirebaseAuth.instance;
  static final _database = FirebaseDatabase.instance;

  // Authentication
  static User? get currentUser => _auth.currentUser;
  
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Chat Rooms
  static DatabaseReference get chatRoomsRef => _database.ref().child('chat_rooms');
  
  static DatabaseReference getChatMessagesRef(String chatRoomId) {
    return _database.ref().child('chat_messages').child(chatRoomId);
  }

  // Group chat (public)
  static DatabaseReference get messagesRef => _database.ref().child('messages');
  
  static DatabaseReference get usersRef => _database.ref().child('users');

  static Future<void> sendMessage(String text, {String? chatRoomId, String? imageUrl}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageData = {
      'text': text,
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'userPhoto': user.photoURL,
      'timestamp': ServerValue.timestamp,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    if (chatRoomId != null) {
      // Private chat message
      await getChatMessagesRef(chatRoomId).push().set(messageData);
      
      // Update chat room last message
      final lastMessageText = imageUrl != null 
          ? (text.isNotEmpty ? text : '📷 Hình ảnh')
          : text;
      
      await chatRoomsRef.child(chatRoomId).update({
        'lastMessage': lastMessageText,
        'lastMessageSender': user.uid,
        'lastMessageTime': ServerValue.timestamp,
      });
    } else {
      // Group chat message
      await messagesRef.push().set(messageData);
    }
  }

  static Stream<DatabaseEvent> getMessagesStream({String? chatRoomId}) {
    if (chatRoomId != null) {
      return getChatMessagesRef(chatRoomId).orderByChild('timestamp').onValue;
    } else {
      return messagesRef.orderByChild('timestamp').onValue;
    }
  }

  // Private Chat Management
  static Future<String> createOrGetPrivateChat(String friendId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final chatRoomId = ChatRoom.createPrivateChatId(user.uid, friendId);
    final chatRoomRef = chatRoomsRef.child(chatRoomId);

    // Check if chat room already exists
    final snapshot = await chatRoomRef.get();
    if (!snapshot.exists) {
      // Get friend's info
      final friendSnapshot = await usersRef.child(friendId).get();
      final friendData = Map<String, dynamic>.from(friendSnapshot.value as Map);

      // Create new private chat room
      await chatRoomRef.set({
        'type': 'private',
        'participants': [user.uid, friendId],
        'name': friendData['displayName'] ?? 'Private Chat',
        'createdAt': ServerValue.timestamp,
        'lastMessage': null,
        'lastMessageSender': null,
        'lastMessageTime': 0,
      });
    }

    return chatRoomId;
  }

  // Get user's chat rooms
  static Stream<DatabaseEvent> getChatRoomsStream() {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    return chatRoomsRef.orderByChild('participants').onValue;
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await user.updateDisplayName(displayName);
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    // Update in Realtime Database
    await usersRef.child(user.uid).set({
      'email': user.email,
      'displayName': displayName ?? user.displayName,
      'photoURL': photoURL ?? user.photoURL,
      'lastSeen': ServerValue.timestamp,
    });
  }

  static Future<void> updateUserLastSeen() async {
    final user = currentUser;
    if (user == null) return;

    await usersRef.child(user.uid).update({
      'lastSeen': ServerValue.timestamp,
    });
  }
}