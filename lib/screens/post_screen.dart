import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ingredientController = TextEditingController();
  final _quantityController = TextEditingController();
  final _regionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postService = PostService();
  bool _isLoading = false;

  final List<String> regions = [
    'Hà Nội',
    'TP.HCM',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
    'Biên Hòa',
    'Nha Trang',
    'Đà Lạt',
  ];

  @override
  void dispose() {
    _ingredientController.dispose();
    _quantityController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập trước')),
          );
        }
        return;
      }

      await _postService.createPost(
        ingredientName: _ingredientController.text.trim(),
        quantity: _quantityController.text.trim(),
        region: _regionController.text.trim(),
        description: _descriptionController.text.trim(),
        userName: currentUser.displayName ?? currentUser.email ?? 'Ẩn danh',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bài thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bài chia sẻ'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Tên nguyên liệu *',
                    hintText: 'VD: Rau cải, Cà chua...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên nguyên liệu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Số lượng *',
                    hintText: 'VD: 10 kg, 5 cái...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số lượng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Khu vực / Tỉnh *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  value: _regionController.text.isEmpty ? null : _regionController.text,
                  items: regions
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _regionController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn khu vực';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả thêm',
                    hintText: 'Mô tả chi tiết về sản phẩm...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'Mô tả không quá 500 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitPost,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Đăng bài',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
