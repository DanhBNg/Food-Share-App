import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../utils/chat_utils.dart';
import '../services/image_upload_service.dart';

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
  final _imageService = ImageUploadService();
  bool _isSending = false;

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
    await _sendChat(text: text);
  }

  Future<void> _sendChat({String text = '', String? imageUrl}) async {
    if (_isSending) return;
    if (text.isEmpty && (imageUrl == null || imageUrl.isEmpty)) return;

    _isSending = true;
    try {
      await _doSend(text: text, imageUrl: imageUrl);
    } finally {
      _isSending = false;
    }
  }

  Future<void> _doSend({String text = '', String? imageUrl}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final msgRef = FirebaseDatabase.instance.ref('messages/$chatId').push();

    await msgRef.set({
      'senderId': currentUser.uid,
      'receiverId': widget.receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': now, // 🔥 BẮT BUỘC – KHÔNG ĐƯỢC NULL
      'seenBy': {
        currentUser.uid: true,
      },
    });

    final lastMessagePreview =
        text.isNotEmpty ? text : (imageUrl != null ? '[Ảnh]' : '');

    await FirebaseDatabase.instance.ref('chatRooms/$chatId').update({
      'lastMessage': lastMessagePreview,
      'lastMessageTime': now,
      'lastSenderId': currentUser.uid,
    });

    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    if (_isSending) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final Uint8List bytes = await image.readAsBytes();
    final ext = image.name.split('.').last;

    _isSending = true;
    try {
      final imageUrl = await _imageService.uploadPostImage(
        bytes: bytes,
        extension: ext,
      );

      if (imageUrl != null) {
        await _doSend(
          text: _messageController.text.trim(),
          imageUrl: imageUrl,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tải ảnh thất bại, vui lòng thử lại')),
          );
        }
      }
    } finally {
      _isSending = false;
    }
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
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg['senderId'] == currentUser.uid;
                    final timestamp = msg['createdAt'] as int;
                    final timeText = DateFormat('HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(timestamp),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment:
                            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar bên trái (người khác)
                          if (!isMe) ...[
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.receiverId)
                                  .get(),
                              builder: (context, snapshot) {
                                String displayName = 'Ẩn danh';
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                                  displayName = data?['name'] ?? 'Ẩn danh';
                                }
                                return CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Nội dung tin nhắn
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.green
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ảnh (nếu có)
                                  if (msg['imageUrl'] != null &&
                                      (msg['imageUrl'] as String).isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        msg['imageUrl'],
                                        width: 220,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) => Container(
                                          width: 220,
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  if ((msg['imageUrl'] != null && (msg['imageUrl'] as String).isNotEmpty) &&
                                      (msg['text'] as String? ?? '').isNotEmpty)
                                    const SizedBox(height: 8),

                                  // Nội dung tin nhắn
                                  if ((msg['text'] as String? ?? '').isNotEmpty)
                                    Text(
                                      msg['text'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isMe ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  const SizedBox(height: 6),

                                  // Thời gian + trạng thái
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        timeText,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.done_all,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Avatar bên phải (của mình)
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                String displayName = 'Mình';
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                                  displayName = data?['name'] ?? 'Mình';
                                }
                                return CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.green.withOpacity(0.15),
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : 'M',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.photo, color: Colors.green.shade700),
                    onPressed: _pickAndSendImage,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
