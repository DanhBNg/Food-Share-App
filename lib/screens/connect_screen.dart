import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/chat_utils.dart';

class ConnectScreen extends StatefulWidget {
  final String receiverId;

  const ConnectScreen({super.key, required this.receiverId});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _messageController = TextEditingController();
  late String chatId;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    chatId = getChatId(currentUser.uid, widget.receiverId);
    _createChatRoomIfNotExists();
    _markSeen();
  }

  Future<void> _createChatRoomIfNotExists() async {
    final ref = FirebaseDatabase.instance.ref('chatRooms/$chatId');
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'members': {
          currentUser.uid: true,
          widget.receiverId: true,
        },
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'lastSenderId': '',
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final msgRef =
    FirebaseDatabase.instance.ref('messages/$chatId').push();

    await msgRef.set({
      'senderId': currentUser.uid,
      'receiverId': widget.receiverId,
      'text': text,
      'imageUrl': null,
      'createdAt': now, // 🔥 BẮT BUỘC – KHÔNG ĐƯỢC NULL
      'seenBy': {
        currentUser.uid: true,
      },
    });

    await FirebaseDatabase.instance.ref('chatRooms/$chatId').update({
      'lastMessage': text,
      'lastMessageTime': now,
      'lastSenderId': currentUser.uid,
    });

    _messageController.clear();
  }

  Future<void> _markSeen() async {
    final ref = FirebaseDatabase.instance.ref('messages/$chatId');
    final snapshot = await ref.get();

    if (!snapshot.exists) return;

    for (final msg in snapshot.children) {
      msg.ref.child('seenBy/${currentUser.uid}').set(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Đang tải...');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Ẩn danh');
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;

            final name = data?['name'];
            return Text(
              (name != null && name.toString().trim().isNotEmpty)
                  ? name
                  : 'Ẩn danh',
            );
          },

        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('messages/$chatId')
                  .orderByChild('createdAt')
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('Chưa có tin nhắn'));
                }

                final rawData = snapshot.data!.snapshot.value as Map;
                final messages = rawData.values
                    .where((msg) => msg['createdAt'] != null)
                    .toList();

                messages.sort((a, b) =>
                    (a['createdAt'] as int)
                        .compareTo(b['createdAt'] as int));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
