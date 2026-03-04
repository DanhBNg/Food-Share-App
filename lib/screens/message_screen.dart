import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'connect_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn',
          style: TextStyle(
          color: Colors.white,
            fontSize: 18,
          fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1976D2),
                Color(0xFFFBC2EB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref('chatRooms')
            .orderByChild('members/${currentUser.uid}')
            .equalTo(true)
            .onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Chưa có cuộc trò chuyện'));
          }

          final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final rooms = data.entries.toList();
          rooms.sort((a, b) {
            final t1 = (a.value['lastMessageTime'] ?? 0) as int;
            final t2 = (b.value['lastMessageTime'] ?? 0) as int;
            return t2.compareTo(t1);
          });


          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final room = rooms[index].value;
              final members = Map<String, dynamic>.from(room['members']);
              final otherUserId = members.keys
                  .firstWhere((id) => id != currentUser.uid, orElse: () => '');

              // Bỏ qua nếu không tìm thấy user khác
              if (otherUserId.isEmpty) {
                return const SizedBox.shrink();
              }

              final lastMessage = room['lastMessage'] ?? '';
              final lastMessageTime = room['lastMessageTime'] ?? 0;
              final lastSenderId = room['lastSenderId'] ?? '';
              final isUnread = lastSenderId != currentUser.uid;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnap) {
                  String displayName = 'Ẩn danh';

                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('...'),
                    );
                  } else if (userSnap.hasData && userSnap.data!.exists) {
                    final data = userSnap.data!.data() as Map<String, dynamic>?;
                    final name = data?['name'];
                    if (name != null && name.toString().trim().isNotEmpty) {
                      displayName = name;
                    }
                  }

                  // Format thời gian
                  String timeText = '';
                  if (lastMessageTime > 0) {
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(lastMessageTime);
                    final now = DateTime.now();
                    
                    if (dateTime.year == now.year &&
                        dateTime.month == now.month &&
                        dateTime.day == now.day) {
                      timeText = DateFormat('HH:mm').format(dateTime);
                    } else {
                      final difference = now.difference(dateTime);
                      if (difference.inDays < 7) {
                        timeText = DateFormat('E', 'vi').format(dateTime);
                      } else {
                        timeText = DateFormat('dd/MM').format(dateTime);
                      }
                    }
                  }

                  final photoUrl = (userSnap.data?.data() as Map<String, dynamic>?)?['photo'] as String?;
                  final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectScreen(
                            receiverId: otherUserId,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          hasPhoto
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _InitialAvatar(displayName: displayName);
                                    },
                                  ),
                                )
                              : _InitialAvatar(displayName: displayName),
                          const SizedBox(width: 12),
                          
                          // Nội dung
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (timeText.isNotEmpty)
                                      Text(
                                        timeText,
                                        style: TextStyle(
                                          fontSize: 12,
                                              color: isUnread
                                                ? const Color(0xFF4F8CFF)
                                                : Colors.grey[600],
                                          fontWeight: isUnread
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (lastSenderId == currentUser.uid)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        lastMessage,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: isUnread
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F8CFF),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String displayName;
  const _InitialAvatar({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFF4F8CFF).withOpacity(0.15),
      child: Text(
        displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'U',
        style: const TextStyle(
          color: Color(0xFF4F8CFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
