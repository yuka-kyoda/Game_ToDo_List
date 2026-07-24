import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final UserService _userService =
      UserService();

  final TextEditingController
      _usernameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _bioController =
      TextEditingController();

  final ImagePicker _picker =
      ImagePicker();

  File? _selectedImage;

  bool _isLoading = true;

  String _avatarUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final profile =
        await _userService.getUserProfile(uid);

    if (profile != null) {
      _usernameController.text =
          profile.username;

      _emailController.text =
          profile.email;

      _bioController.text =
          profile.bio;

      _avatarUrl =
          profile.avatarUrl;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage =
          File(image.path);
    });
  }

  Future<void> _saveProfile() async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    String avatarUrl =
        _avatarUrl;

    // 新しい画像が選択されていればアップロード
    if (_selectedImage != null) {
      avatarUrl =
          await _userService.uploadAvatar(
        _selectedImage!,
      );
    }

    final profile = UserProfile(
      uid: uid,
      username:
          _usernameController.text.trim(),
      email:
          _emailController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: avatarUrl,
    );

    await _userService.updateProfile(
      profile,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "プロフィールを更新しました",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "プロフィール編集",
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            CircleAvatar(
              radius: 60,
              backgroundImage:
                  _selectedImage != null
                      ? FileImage(
                          _selectedImage!,
                        )
                      : (_avatarUrl.isNotEmpty
                          ? NetworkImage(
                              _avatarUrl,
                            )
                          : null),
              child:
                  _selectedImage == null &&
                          _avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton.icon(
              onPressed:
                  _pickImage,
              icon: const Icon(
                Icons.photo_camera,
              ),
              label: const Text(
                "画像を変更",
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(
              controller:
                  _usernameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "ユーザー名",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _emailController,
              enabled: false,
              decoration:
                  const InputDecoration(
                labelText:
                    "メールアドレス",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _bioController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                labelText:
                    "自己紹介",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    _saveProfile,
                child: const Text(
                  "保存",
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  "キャンセル",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}