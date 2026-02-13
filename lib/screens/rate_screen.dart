import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/rating_service.dart';
import '../models/rating_model.dart';
import 'connect_screen.dart';

class RateScreen extends StatelessWidget {
  final String userId;

  const RateScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Đánh giá người dùng",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFFFBC2EB)],
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final isOwner = currentUser?.uid == userId;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// ===== CARD THÔNG TIN USER =====
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage:
                      (userData['photo'] != null &&
                          userData['photo'].toString().isNotEmpty)
                          ? NetworkImage(userData['photo'])
                          : null,
                      child: (userData['photo'] == null ||
                          userData['photo'].toString().isEmpty)
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      userData['name'] ?? "Ẩn danh",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(userData['address'] ?? ""),
                    trailing: !isOwner
                        ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Liên hệ"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConnectScreen(receiverId: userId),
                          ),
                        );
                      },
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                /// ===== FORM ĐÁNH GIÁ =====
                if (!isOwner)
                  _RatingForm(
                    userId: userId,
                  ),

                const SizedBox(height: 10),

                /// ===== LIST =====
                const Expanded(
                  child: _RatingList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ==================== FORM ================================
///////////////////////////////////////////////////////////////

class _RatingForm extends StatefulWidget {
  final String userId;

  const _RatingForm({required this.userId});

  @override
  State<_RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<_RatingForm> {
  final _service = RatingService();
  final contentCtrl = TextEditingController();

  String selectedType = "Tốt";

  final types = [
    "Tốt",
    "Tạm ổn",
    "Tệ",
    "Chất lượng hàng tốt",
    "Giao hàng nhanh",
    "Đa dạng",
    "Thân thiện",
    "Không uy tín"
  ];

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung")),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final rating = Rating(
      id: '',
      targetUserId: widget.userId,
      fromUserId: user.uid,
      fromName: userDoc.data()?['name'] ?? 'Ẩn danh',
      fromPhoto: userDoc.data()?['photo'] ?? '',
      type: selectedType,
      content: contentCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    await _service.addRating(rating);

    contentCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã gửi đánh giá")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Viết đánh giá",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            /// CHIP CHỌN NHANH
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: types.map((type) {
                final isSelected = selectedType == type;

                Color bgColor = Colors.grey.shade200;
                Color textColor = Colors.black87;

                if (isSelected) {
                  switch (type) {
                    case "Tốt":
                      bgColor = Colors.green.shade100;
                      textColor = Colors.green.shade800;
                      break;
                    case "Tạm ổn":
                      bgColor = Colors.orange.shade100;
                      textColor = Colors.orange.shade800;
                      break;
                    case "Tệ":
                    case "Không uy tín":
                      bgColor = Colors.red.shade100;
                      textColor = Colors.red.shade800;
                      break;
                    default:
                      bgColor = Colors.blue.shade100;
                      textColor = Colors.blue.shade800;
                  }
                }

                return ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: bgColor,
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: contentCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Nhập nhận xét...",
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Gửi đánh giá",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ==================== LIST ================================
///////////////////////////////////////////////////////////////

class _RatingList extends StatelessWidget {
  const _RatingList();

  @override
  Widget build(BuildContext context) {
    final service = RatingService();
    final userId =
        (context.findAncestorWidgetOfExactType<RateScreen>()!).userId;

    return StreamBuilder<List<Rating>>(
      stream: service.getRatingsOfUser(userId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text("Lỗi: ${snap.error}"));
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final ratings = snap.data!;

        if (ratings.isEmpty) {
          return const Center(child: Text("Chưa có đánh giá nào"));
        }

        ratings.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
        );

        return ListView.builder(
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final r = ratings[index];

            Color bgColor = Colors.grey.shade200;
            Color textColor = Colors.grey.shade800;

            switch (r.type) {
              case "Tốt":
                bgColor = Colors.green.shade100;
                textColor = Colors.green.shade800;
                break;
              case "Tạm ổn":
                bgColor = Colors.orange.shade100;
                textColor = Colors.orange.shade800;
                break;
              case "Tệ":
              case "Không uy tín":
                bgColor = Colors.red.shade100;
                textColor = Colors.red.shade800;
                break;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.fromName.isNotEmpty ? r.fromName : "Ẩn danh",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.type,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (r.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      r.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
