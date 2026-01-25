import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../services/image_upload_service.dart';
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

  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageExtension;
  final _imageService = ImageUploadService();

  final _postService = PostService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }


  @override
  void dispose() {
    _ingredientController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      final address = data?['address'];

      if (address != null && address.toString().isNotEmpty) {
        _addressController.text = address;
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = image.name.split('.').last;
      });
    }
  }

  Future<void> _submitPost() async {
    String? imageUrl;

    if (_imageBytes != null && _imageExtension != null) {
      imageUrl = await _imageService.uploadPostImage(
        bytes: _imageBytes!,
        extension: _imageExtension!,
      );
    }
    if (_isLoading) return; // chặn spam click

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
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bài thành công!'),
            backgroundColor: Color(0xFF4F8CFF),
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

// up anh
  Future<String?> _uploadImageToSupabase(File image) async {
    final supabase = Supabase.instance.client;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('post-images')
        .upload(fileName, image);

    final publicUrl = supabase.storage
        .from('post-images')
        .getPublicUrl(fileName);

    return publicUrl;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bài chia sẻ'),
        backgroundColor: const Color(0xFF4F8CFF),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F8CFF),
            ),
            onPressed: _submitPost,
            child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF4F8CFF))
                : const Text('Đăng bài',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                ),
          ),
        ),
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
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ *',
                    hintText: 'VD: 123 Lê Lợi, Quận 1, TP.HCM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.place),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
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
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF4F8CFF)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imageBytes == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 40, color: Color(0xFF4F8CFF)),
                        SizedBox(height: 8),
                        Text('Chọn ảnh sản phẩm'),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SizedBox(
                //   width: double.infinity,
                //   height: 50,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.green,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //     onPressed: _isLoading ? null : _submitPost,
                //     child: _isLoading
                //         ? const SizedBox(
                //             height: 24,
                //             width: 24,
                //             child: CircularProgressIndicator(
                //               valueColor:
                //                   AlwaysStoppedAnimation<Color>(Colors.white),
                //               strokeWidth: 2,
                //             ),
                //           )
                //         : const Text(
                //             'Đăng bài',
                //             style: TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //             ),
                //           ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
