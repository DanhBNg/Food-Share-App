import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _database = FirebaseDatabase.instance;
  static final _googleSignIn = GoogleSignIn();

  // Current user
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Auth
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _updateUserStatus(credential.user!);
    return credential;
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await credential.user!.updateDisplayName(displayName);
    await _createUserProfile(credential.user!);
    return credential;
  }

  // Google Sign-in
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from any previous Google account first
      await _googleSignIn.signOut();
      
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        print('Google Sign-in cancelled by user');
        return null;
      }

      print('Google user: ${googleUser.email}');

      // Get the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('Access token: ${googleAuth.accessToken != null ? "exists" : "null"}');
      print('ID token: ${googleAuth.idToken != null ? "exists" : "null"}');

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase...');

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase sign-in successful: ${userCredential.user?.email}');
      
      // Create or update user profile
      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);
        print('User profile created/updated');
      }
      
      return userCredential;
    } catch (e) {
      print('Google sign-in error: $e');
      
      // Provide more specific error messages
      String errorMessage = 'Đăng nhập Google thất bại';
      
      if (e.toString().contains('network_error') || e.toString().contains('NetworkError')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      } else if (e.toString().contains('sign_in_canceled') || e.toString().contains('ERROR_ABORTED_BY_USER')) {
        return null; // User cancelled, don't show error
      } else if (e.toString().contains('sign_in_failed') || e.toString().contains('ERROR_SIGN_IN_FAILED')) {
        errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      } else if (e.toString().contains('account-exists-with-different-credential')) {
        errorMessage = 'Email này đã được sử dụng với phương thức đăng nhập khác.';
      } else if (e.toString().contains('invalid-credential')) {
        errorMessage = 'Thông tin xác thực không hợp lệ.';
      }
      
      throw Exception(errorMessage);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _updateUserOfflineStatus();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // User profile management
  static Future<void> _createUserProfile(User user) async {
    final userRef = _database.ref().child('users').child(user.uid);
    
    await userRef.set({
      'email': user.email,
      'displayName': user.displayName ?? 'User',
      'photoURL': user.photoURL,
      'isOnline': true,
      'lastSeen': ServerValue.timestamp,
      'status': 'Available',
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> _updateUserStatus(User user) async {
    final userRef = _database.ref().child('users').child(user.uid);
    await userRef.update({
      'isOnline': true,
      'lastSeen': ServerValue.timestamp,
    });
  }

  static Future<void> _updateUserOfflineStatus() async {
    final user = currentUser;
    if (user == null) return;

    final userRef = _database.ref().child('users').child(user.uid);
    await userRef.update({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Friend management
  static Future<void> sendFriendRequest(String friendId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final requestRef = _database.ref().child('friend_requests').child(friendId).child(user.uid);
    await requestRef.set({
      'senderId': user.uid,
      'senderName': user.displayName,
      'senderEmail': user.email,
      'senderPhoto': user.photoURL,
      'timestamp': ServerValue.timestamp,
      'status': 'pending',
    });
  }

  static Future<void> acceptFriendRequest(String senderId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Add to friends list
    await _database.ref().child('friends').child(user.uid).child(senderId).set(true);
    await _database.ref().child('friends').child(senderId).child(user.uid).set(true);

    // Remove friend request
    await _database.ref().child('friend_requests').child(user.uid).child(senderId).remove();
  }

  static Future<void> declineFriendRequest(String senderId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _database.ref().child('friend_requests').child(user.uid).child(senderId).remove();
  }

  // Get friends
  static Stream<DatabaseEvent> getFriendsStream() {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    return _database.ref().child('friends').child(user.uid).onValue;
  }

  // Get friend requests
  static Stream<DatabaseEvent> getFriendRequestsStream() {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    return _database.ref().child('friend_requests').child(user.uid).onValue;
  }

  // Search users - tìm kiếm thông minh
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('🔍 Searching for: "$query"');
      
      // Lấy tất cả users trước, sau đó filter ở client
      final snapshot = await _database.ref().child('users').get();
      
      print('📊 Database snapshot exists: ${snapshot.exists}');
      
      final users = <Map<String, dynamic>>[];
      if (snapshot.exists && snapshot.value != null) {
        // Safely cast the data
        final rawData = snapshot.value;
        Map<String, dynamic> data;
        
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is Map) {
          // Convert Map<Object?, Object?> to Map<String, dynamic>
          data = Map<String, dynamic>.from(rawData);
        } else {
          print('❌ Unexpected data type: ${rawData.runtimeType}');
          return [];
        }
        
        print('👥 Total users in database: ${data.length}');
        print('🔑 Current user ID: ${currentUser?.uid}');
        
        data.forEach((key, value) {
          try {
            if (key != currentUser?.uid && value != null) {
              // Safely convert user data
              Map<String, dynamic> userData;
              if (value is Map<String, dynamic>) {
                userData = value;
              } else if (value is Map) {
                userData = Map<String, dynamic>.from(value);
              } else {
                print('⚠️ Skipping user $key - invalid data type: ${value.runtimeType}');
                return;
              }
              
              final displayName = userData['displayName']?.toString().toLowerCase() ?? '';
              final email = userData['email']?.toString().toLowerCase() ?? '';
              final queryLower = query.toLowerCase().trim();
              
              print('🔍 Checking user: $key');
              print('  - Name: "$displayName"');
              print('  - Email: "$email"');
              
              // Tìm kiếm thông minh: tên, email, hoặc một phần email trước @
              bool matches = false;
              
              // Tìm theo tên
              if (displayName.contains(queryLower)) {
                matches = true;
                print('  ✅ Match by name');
              }
              
              // Tìm theo email đầy đủ
              if (email.contains(queryLower)) {
                matches = true;
                print('  ✅ Match by email');
              }
              
              // Tìm theo username (phần trước @ trong email)
              if (email.isNotEmpty && queryLower.isNotEmpty) {
                final username = email.split('@')[0];
                if (username.contains(queryLower)) {
                  matches = true;
                  print('  ✅ Match by username: $username');
                }
              }
              
              // Tìm theo từng từ trong tên
              if (!matches && displayName.isNotEmpty && queryLower.isNotEmpty) {
                final nameWords = displayName.split(' ');
                for (String word in nameWords) {
                  if (word.startsWith(queryLower) || word.contains(queryLower)) {
                    matches = true;
                    print('  ✅ Match by name word: "$word"');
                    break;
                  }
                }
              }
              
              if (matches) {
                users.add({
                  'id': key,
                  ...userData,
                });
                print('  ➕ Added to results');
              } else {
                print('  ❌ No match');
              }
            }
          } catch (e) {
            print('⚠️ Error processing user $key: $e');
          }
        });
      }
      
      print('🎯 Total search results: ${users.length}');
      
      // Sắp xếp kết quả theo độ liên quan
      users.sort((a, b) {
        final aName = a['displayName']?.toString().toLowerCase() ?? '';
        final aEmail = a['email']?.toString().toLowerCase() ?? '';
        final bName = b['displayName']?.toString().toLowerCase() ?? '';
        final bEmail = b['email']?.toString().toLowerCase() ?? '';
        final queryLower = query.toLowerCase();
        
        // Ưu tiên tên bắt đầu bằng query
        if (aName.startsWith(queryLower) && !bName.startsWith(queryLower)) return -1;
        if (bName.startsWith(queryLower) && !aName.startsWith(queryLower)) return 1;
        
        // Sau đó ưu tiên email bắt đầu bằng query
        if (aEmail.startsWith(queryLower) && !bEmail.startsWith(queryLower)) return -1;
        if (bEmail.startsWith(queryLower) && !aEmail.startsWith(queryLower)) return 1;
        
        // Cuối cùng sắp xếp theo tên
        return aName.compareTo(bName);
      });
      
      print('✅ Search completed successfully');
      return users;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // Đề xuất kết bạn - suggest friends
  static Future<List<Map<String, dynamic>>> getSuggestedFriends() async {
    try {
      final user = currentUser;
      if (user == null) return [];

      // Lấy danh sách bạn bè hiện tại
      final currentFriendsSnapshot = await _database.ref()
          .child('friends')
          .child(user.uid)
          .get();
      
      final currentFriends = <String>[];
      if (currentFriendsSnapshot.exists && currentFriendsSnapshot.value != null) {
        final rawData = currentFriendsSnapshot.value;
        Map<String, dynamic> data;
        
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        } else {
          data = {};
        }
        currentFriends.addAll(data.keys);
      }

      // Lấy danh sách friend requests đã gửi
      final sentRequestsSnapshot = await _database.ref()
          .child('friend_requests')
          .get();
      
      final sentRequests = <String>[];
      final receivedRequests = <String>[];
      if (sentRequestsSnapshot.exists && sentRequestsSnapshot.value != null) {
        final rawData = sentRequestsSnapshot.value;
        Map<String, dynamic> data;
        
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        } else {
          data = {};
        }
        
        data.forEach((receiverId, requests) {
          try {
            if (requests != null) {
              Map<String, dynamic> requestsData;
              if (requests is Map<String, dynamic>) {
                requestsData = requests;
              } else if (requests is Map) {
                requestsData = Map<String, dynamic>.from(requests);
              } else {
                return;
              }
              
              // Kiểm tra requests đã gửi
              if (requestsData.containsKey(user.uid)) {
                sentRequests.add(receiverId);
              }
              // Kiểm tra requests đã nhận
              if (receiverId == user.uid) {
                requestsData.forEach((senderId, _) {
                  receivedRequests.add(senderId);
                });
              }
            }
          } catch (e) {
            print('Error processing friend request for $receiverId: $e');
          }
        });
      }

      // Lấy tất cả users
      final usersSnapshot = await _database.ref().child('users').get();
      final suggestions = <Map<String, dynamic>>[];

      if (usersSnapshot.exists && usersSnapshot.value != null) {
        final rawData = usersSnapshot.value;
        Map<String, dynamic> data;
        
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        } else {
          return [];
        }
        
        data.forEach((userId, userData) {
          try {
            // Loại trừ chính mình, bạn bè hiện tại, và những người đã gửi/nhận request
            if (userId != user.uid && 
                !currentFriends.contains(userId) && 
                !sentRequests.contains(userId) && 
                !receivedRequests.contains(userId) &&
                userData != null) {
              
              Map<String, dynamic> userMap;
              if (userData is Map<String, dynamic>) {
                userMap = userData;
              } else if (userData is Map) {
                userMap = Map<String, dynamic>.from(userData);
              } else {
                return;
              }
              
              userMap['id'] = userId;
              suggestions.add(userMap);
            }
          } catch (e) {
            print('Error processing user suggestion for $userId: $e');
          }
        });
      }

      // Sắp xếp theo thời gian tạo tài khoản (mới nhất trước)
      suggestions.sort((a, b) {
        final aCreated = a['createdAt'] ?? 0;
        final bCreated = b['createdAt'] ?? 0;
        if (aCreated is int && bCreated is int) {
          return bCreated.compareTo(aCreated);
        }
        return 0;
      });

      // Giới hạn 20 đề xuất
      return suggestions.take(20).toList();
    } catch (e) {
      print('Error getting suggested friends: $e');
      return [];
    }
  }
}