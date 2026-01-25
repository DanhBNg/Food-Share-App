class Friend {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isOnline;
  final int lastSeen;
  final String status;

  Friend({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isOnline = false,
    required this.lastSeen,
    this.status = '',
  });

  factory Friend.fromMap(String id, Map<String, dynamic> map) {
    return Friend(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? 0,
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'status': status,
    };
  }
}