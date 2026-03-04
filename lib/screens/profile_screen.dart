import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../services/image_upload_service.dart';
import 'buy_package_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final usersRef = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();
  final _imageUploadService = ImageUploadService();

  bool isEditing = false;
  bool _didLoad = false;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  File? pickedImage;

  String completePhoneNumber = "";
  String initialCountryCode = "VN";

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  /// ================= PHONE PARSE (FIX ASYNC ERROR) =================
  Future<void> _parsePhoneAsync(String phoneFromDb) async {
    if (phoneFromDb.isEmpty) return;

    if (phoneFromDb.startsWith('+')) {
      completePhoneNumber = phoneFromDb;

      try {
        PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneFromDb);

        if (!mounted) return;

        setState(() {
          initialCountryCode = number.isoCode ?? "VN";

          String dialCode = number.dialCode ?? "";
          phoneCtrl.text =
              phoneFromDb.replaceFirst("+$dialCode", "");
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          initialCountryCode = "VN";
          phoneCtrl.text = phoneFromDb;
        });
      }
    } else {
      phoneCtrl.text = phoneFromDb;
    }
  }

  /// ================= AVATAR =================
  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => pickedImage = File(result.path));
    }
  }

  Future<String?> uploadAvatarWithSupabase(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last;

      return await _imageUploadService.uploadPostImage(
        bytes: bytes,
        extension: extension,
      );
    } catch (e) {
      debugPrint('Supabase upload error: $e');
      return null;
    }
  }

  /// ================= SAVE PROFILE =================
  Future<void> saveProfile(BuildContext scaffoldContext) async {
    if (!_formKey.currentState!.validate()) return;

    String? photoUrl;

    if (pickedImage != null) {
      photoUrl = await uploadAvatarWithSupabase(pickedImage!);
      if (photoUrl != null) {
        await user!.updatePhotoURL(photoUrl);
        await user!.reload();
      }
    }

    await usersRef.doc(user!.uid).set({
      'name': nameCtrl.text.trim(),
      'phone': completePhoneNumber,
      'address': addressCtrl.text.trim(),
      if (photoUrl != null) 'photo': photoUrl,
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() {
      isEditing = false;
      pickedImage = null;
    });

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(content: Text('Lưu thông tin thành công')),
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Chưa đăng nhập')),
      );
    }

    return Builder(
      builder: (scaffoldContext) => Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          title: const Text(
            'Trang cá nhân',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFFFBC2EB),
                ],
              ),
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: usersRef.doc(user!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};

            /// LOAD DATA ONCE (NO AWAIT HERE)
            if (!_didLoad) {
              nameCtrl.text = data['name'] ?? user!.displayName ?? '';
              addressCtrl.text = data['address'] ?? '';

              String phoneFromDb = data['phone'] ?? "";

              // Gọi async sau build frame
              Future.microtask(() {
                _parsePhoneAsync(phoneFromDb);
              });

              _didLoad = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
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
                              : null))
                          as ImageProvider?,
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
                    const SizedBox(height: 24),

                    _buildField('Họ tên', nameCtrl, isEditing),

                    _buildField(
                      'Email',
                      TextEditingController(text: user!.email ?? ''),
                      false,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: IntlPhoneField(
                        controller: phoneCtrl,
                        enabled: isEditing,
                        initialCountryCode: initialCountryCode,
                        autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: 'SĐT',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (phone) {
                          completePhoneNumber =
                              phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null ||
                              phone.number.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          if (!phone.isValidNumber()) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),

                    _buildField('Địa chỉ', addressCtrl, isEditing),

                    const SizedBox(height: 24),

                    _buildActionBtn(
                      isEditing ? 'Lưu thông tin' : 'Chỉnh sửa',
                      isEditing ? Icons.save : Icons.edit,
                      isEditing
                          ? const Color(0xFF4F8CFF)
                          : Colors.blue,
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
                      'Quản lý bài đăng',
                      Icons.list_alt,
                      Colors.orange,
                          () {
                        Navigator.pushNamed(
                            context, '/manage_posts');
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildActionBtn(
                      'Mua gói đăng tin',
                      Icons.workspace_premium,
                      Colors.teal,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const BuyPackageScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildActionBtn(
                      'Đăng xuất',
                      Icons.logout,
                      Colors.red,
                          () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (r) => false);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController ctrl, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        validator: (value) {
          if (enabled && (value == null || value.isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      String text,
      IconData icon,
      Color color,
      VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text,
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}