import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_share/screens/post_detail_screen.dart';

import '../models/post_model.dart';
import '../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  List<Post> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _onSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final data = await _searchService.searchPosts(keyword);
      setState(() {
        _results = data;
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm + nút search
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên nguyên liệu...',
                      //prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _onSearch,
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? const Center(
              child: Text(
                'Chưa có dữ liệu tìm kiếm',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : _results.isEmpty
                ? const Center(
              child: Text(
                'Không tìm thấy kết quả',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final post = _results[index];
                return _PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.ingredientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.scale, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Số lượng: ${post.quantity}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.description, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post.description.isEmpty
                              ? 'Không có mô tả'
                              : post.description,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(post.userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String userName = post.userName;

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                        snapshot.data!.data() as Map<String, dynamic>?;
                        userName = data?['name'] ?? post.userName;
                      }

                      return Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onTap,
              child: const Text(
                'Chi tiết',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

