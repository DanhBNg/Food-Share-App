import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bài chia sẻ'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Tên nguyên liệu'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Số lượng'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Khu vực / Tỉnh'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Mô tả thêm'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Đăng bài'),
            )
          ],
        ),
      ),
    );
  }
}
