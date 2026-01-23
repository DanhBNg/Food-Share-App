import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final usersRef = FirebaseFirestore.instance.collection('users');

  bool isEditing = false;
  bool _didLoad = false;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  File? pickedImage;

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => pickedImage = File(result.path));
    }
  }


  Future<String?> uploadAvatar(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${user!.uid}.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> saveProfile(BuildContext scaffoldContext) async {
    String? photoUrl;

    if (pickedImage != null) {
      photoUrl = await uploadAvatar(pickedImage!);
      if (photoUrl != null) {
        await user!.updatePhotoURL(photoUrl);
        await user!.reload();
      }
    }

    await usersRef.doc(user!.uid).set({
      'name': nameCtrl.text,
      'phone': phoneCtrl.text,
      'address': addressCtrl.text,
      if (photoUrl != null) 'photo': photoUrl,
    }, SetOptions(merge: true));

    setState(() {
      isEditing = false;
      _didLoad = false;
      pickedImage = null;
    });

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(content: Text('Lưu thông tin thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }

    return Builder(
      builder: (scaffoldContext) => Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(title: const Text('Trang cá nhân'), backgroundColor: Colors.green),
        body: StreamBuilder<DocumentSnapshot>(
          stream: usersRef.doc(user!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            if (!_didLoad) {
              nameCtrl.text = data['name'] ?? user!.displayName ?? '';
              phoneCtrl.text = data['phone'] ?? '';
              addressCtrl.text = data['address'] ?? '';
              _didLoad = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: pickedImage != null
                              ? FileImage(pickedImage!)
                              : (data['photo'] != null
                              ? NetworkImage(data['photo'])
                              : (user!.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null)) as ImageProvider?,
                          child: pickedImage == null &&
                              data['photo'] == null &&
                              user!.photoURL == null
                              ? const Icon(Icons.person,
                              size: 55, color: Colors.grey)
                              : null,
                        ),
                        if (isEditing)
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                              onPressed: pickAvatar,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildField('Họ tên', nameCtrl, isEditing),
                  _buildField(
                      'Email',
                      TextEditingController(text: user!.email ?? ''),
                      false),
                  _buildField('SĐT', phoneCtrl, isEditing),
                  _buildField('Địa chỉ', addressCtrl, isEditing),


                  const SizedBox(height: 24),

                  _buildActionBtn(
                    isEditing ? 'Lưu thông tin' : 'Chỉnh sửa',
                    isEditing ? Icons.save : Icons.edit,
                    isEditing ? Colors.green : Colors.blue,
                        () {
                      if (isEditing) {
                        saveProfile(scaffoldContext);
                      } else {
                        setState(() => isEditing = true);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionBtn(
                      'Quản lý bài đăng', Icons.list_alt, Colors.orange, () {
                    // TODO: chuyển sang màn quản lý bài viết
                  }),
                  const SizedBox(height: 12),

                  _buildActionBtn('Cài đặt', Icons.settings, Colors.purple, () {
                    // TODO: chuyển sang màn cài đặt
                  }),
                  const SizedBox(height: 12),

                  _buildActionBtn('Đăng xuất', Icons.logout, Colors.red, () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (r) => false);
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
