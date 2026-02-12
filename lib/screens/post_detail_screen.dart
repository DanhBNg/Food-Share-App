import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_share/screens/connect_screen.dart';
import 'package:food_share/screens/rate_screen.dart';
import '../models/post_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Builder(
              builder: (context) {
                final currentUser = FirebaseAuth.instance.currentUser;

                final isMyPost =
                    currentUser != null && currentUser.uid == widget.post.userId;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMyPost
                        ? Colors.grey        // nút xám khi là bài của mình
                        : const Color(0xFF4F8CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // vô hiệu hóa nếu là bài của mình
                  onPressed: isMyPost
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectScreen(
                          receiverId: widget.post.userId,
                        ),
                      ),
                    );
                  },

                  child: Text(
                    isMyPost
                        ? 'Đây là bài đăng của bạn'
                        : 'Liên hệ người đăng',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      label: const Text(
                        "Đánh giá về nguười dùng này",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RateScreen(
                              userId: widget.post.userId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Card hiển thị thông tin chính
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên nguyên liệu
                      Row(
                        children: [
                          const Icon(Icons.restaurant, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tên sản phẩm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.post.ingredientName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Số lượng
                      Row(
                        children: [
                          const Icon(Icons.scale, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số lượng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.post.quantity,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      //price
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  formatPrice(widget.post.price),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Khu vực
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Khu vực',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.post.address,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              //url
              if (widget.post.productUrl != null &&
                  widget.post.productUrl!.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'URL sản phẩm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.link, color: Color(0xFF4F8CFF)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => openUrl(widget.post.productUrl!),
                              child: Text(
                                widget.post.productUrl!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Mô tả
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả chi tiết',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.post.description.isNotEmpty
                                  ? widget.post.description
                                  : 'Không có mô tả',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // Thông tin người đăng
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin người đăng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.post.userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String userName = widget.post.userName;
                          
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final userData = snapshot.data!.data() as Map<String, dynamic>?;
                            userName = userData?['name'] ?? widget.post.userName;
                          }

                          return Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF4F8CFF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(userName),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF4F8CFF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(widget.post.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.post.imageUrl != null &&
                  widget.post.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 220,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: Color(0xFF4F8CFF),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
  String formatPrice(String price) {
    final p = price.trim().toLowerCase();

    if (p == '0' || p == 'miễn phí' || p == 'free') {
      return 'Tặng miễn phí';
    }
    // Nếu là số, format có dấu chấm
    final number = int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number != null) {
      final formatter = NumberFormat("#,###", "vi_VN");
      return "${formatter.format(number)} đ";
    }
    return price;
  }

  Future<void> openUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được liên kết')),
      );
    }
  }

}
