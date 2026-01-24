class ChatUser {
  final String id;
  final String email;
  final String displayName;

  ChatUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory ChatUser.fromFirebaseUser(user) {
    return ChatUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Người dùng',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
    };
  }
}