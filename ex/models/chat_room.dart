class ChatRoom {
  final String id;
  final String name;
  final String type; // 'group' hoặc 'private'
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSender;
  final int lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime = 0,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoom(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'private',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      lastMessageTime: map['lastMessageTime'] ?? 0,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }

  // Tạo ID cho private chat từ 2 user IDs
  static String createPrivateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'private_${ids[0]}_${ids[1]}';
  }
}