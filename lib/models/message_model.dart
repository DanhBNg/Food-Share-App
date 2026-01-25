class Message {
  final String senderId;
  final String text;
  final String? imageUrl;
  final int timestamp;
  final bool seen;

  Message({
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    required this.seen,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'seen': seen,
    };
  }
}
