import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'connect_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: Colors.green,
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


          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index].value;
              final members = Map<String, dynamic>.from(room['members']);
              final otherUserId = members.keys
                  .firstWhere((id) => id != currentUser.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnap) {
                  String displayName = 'Ẩn danh';

                  if (userSnap.connectionState == ConnectionState.waiting) {
                    displayName = '...';
                  } else if (userSnap.hasData && userSnap.data!.exists) {
                    final data = userSnap.data!.data() as Map<String, dynamic>?;
                    final name = data?['name'];
                    if (name != null && name.toString().trim().isNotEmpty) {
                      displayName = name;
                    }
                  }

                  return Card(
                    child: ListTile(
                      title: Text(displayName),
                      subtitle: Text(room['lastMessage'] ?? ''),
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
