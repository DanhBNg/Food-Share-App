import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/rating_service.dart';
import '../models/rating_model.dart';
import 'connect_screen.dart';

class RateScreen extends StatefulWidget {
  final String userId;

  const RateScreen({super.key, required this.userId});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  final _service = RatingService();
  final currentUser = FirebaseAuth.instance.currentUser;

  String selectedType = "Tốt";
  final contentCtrl = TextEditingController();

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (contentCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập nội dung")),
        );
        return;
      }

      // 🔥 LẤY TÊN TỪ COLLECTION USERS
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final fromName = userDoc.data()?['name'] ?? "Ẩn danh";
      final fromPhoto = userDoc.data()?['photo'] ?? '';

      final rating = Rating(
        id: '',
        targetUserId: widget.userId,
        fromUserId: user.uid,
        fromName: fromName, //
        fromPhoto: fromPhoto,
        type: selectedType,
        content: contentCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await _service.addRating(rating);

      contentCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gửi đánh giá")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh giá người dùng",
            style: TextStyle(color: Colors.white)),
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
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final isOwner = currentUser?.uid == widget.userId;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // CARD THÔNG TIN USER
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: (userData['photo'] != null &&
                          userData['photo'].toString().isNotEmpty)
                          ? NetworkImage(userData['photo'])
                          : null,
                      child: (userData['photo'] == null ||
                          userData['photo'].toString().isEmpty)
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),


                    title: Text(userData['name'] ?? "Ẩn danh"),
                    subtitle: Text(userData['address'] ?? ""),
                    trailing: !isOwner
                        ? ElevatedButton(
                      child: const Text("Liên hệ"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConnectScreen(
                              receiverId: widget.userId,
                            ),
                          ),
                        );
                      },
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                // FORM VIẾT ĐÁNH GIÁ
                if (!isOwner) Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Đánh giá chung"),

                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: types.map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e))
                          ).toList(),
                          onChanged: (v) =>
                              setState(() => selectedType = v!),
                        ),

                        TextField(
                          controller: contentCtrl,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            hintText: "Nhập nhận xét...",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text("Xác nhận"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const Divider(),

                // LIST ĐÁNH GIÁ
                Expanded(
                  child: StreamBuilder<List<Rating>>(
                    stream: _service.getRatingsOfUser(widget.userId),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Text("Lỗi stream: ${snap.error}"),
                        );
                      }

                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snap.hasData || snap.data!.isEmpty) {
                        return const Text("Chưa có đánh giá nào");
                      }

                      final ratings = snap.data!;
                      ratings.sort(
                            (a, b) => b.createdAt.compareTo(a.createdAt),
                      );


                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          final r = ratings[index];

                          // XỬ LÝ MÀU
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

                            default:
                              bgColor = Colors.grey.shade200;
                              textColor = Colors.grey.shade800;
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //  TÊN NGƯỜI ĐÁNH GIÁ
                                Text(
                                  r.fromName.isNotEmpty ? r.fromName : "Ẩn danh",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Ô MÀU LOẠI ĐÁNH GIÁ (KHÔNG CÒN ICON SAO)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
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
                  ),

                )

              ],
            ),
          );
        },
      ),
    );
  }
}
