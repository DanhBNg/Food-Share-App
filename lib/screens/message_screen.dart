import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Chưa có tin nhắn',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
