import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DemoData {
  static Future<void> addSampleMessages() async {
    final messagesRef = FirebaseDatabase.instance.ref().child('messages');
    
    final sampleMessages = [
      {
        'text': 'Xin chào mọi người! 👋',
        'userId': 'demo_user_1',
        'userName': 'Alice',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
      },
      {
        'text': 'Hôm nay trời đẹp quá!',
        'userId': 'demo_user_2', 
        'userName': 'Bob',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 8)).millisecondsSinceEpoch,
      },
      {
        'text': 'Có ai muốn đi uống cà phê không? ☕',
        'userId': 'demo_user_1',
        'userName': 'Alice',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
      },
      {
        'text': 'Tôi có thể tham gia được!',
        'userId': 'demo_user_3',
        'userName': 'Charlie',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 3)).millisecondsSinceEpoch,
      },
      {
        'text': 'Gặp nhau ở quán quen nhé 😊',
        'userId': 'demo_user_2',
        'userName': 'Bob', 
        'timestamp': DateTime.now().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
      },
    ];

    for (final message in sampleMessages) {
      await messagesRef.push().set(message);
    }
  }

  static Widget buildDemoButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          await addSampleMessages();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm tin nhắn mẫu!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      },
      label: const Text('Thêm demo'),
      icon: const Icon(Icons.add_comment),
      backgroundColor: Colors.orange,
    );
  }
}