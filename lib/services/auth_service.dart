import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // Đăng nhập
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Đăng nhập Google
  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print('Google login error: $e');
      return null;
    }
  }

  // Đăng nhập Facebook
  Future<User?> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken!.token);

      final userCred =
      await _auth.signInWithCredential(facebookAuthCredential);
      return userCred.user;
    } catch (e) {
      print('Facebook login error: $e');
      return null;
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await ref.set({
      'name': user.displayName,
      'email': user.email,
      'photo': user.photoURL,
      'role': 'Người mua',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }

  // User hiện tại
  User? get currentUser => _auth.currentUser;
}
