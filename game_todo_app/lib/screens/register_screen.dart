import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  final UserService _userService =
    UserService();

  bool _loading = false;

  Future<void> _register() async {
    if (_passwordController.text !=
        _confirmController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("パスワードが一致しません"),
        ),
      );

      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      final credential =
          await _authService.register(
        email: _emailController.text.trim(),
        password:
            _passwordController.text.trim(),
      );


      final user =
          credential.user;


      if (user != null) {

        await _userService.createUserProfile(
          UserProfile(
            uid: user.uid,
            username:
                _emailController.text
                    .split('@')[0],
            email:
                user.email ?? '',
          ),
        );

      }

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ユーザー登録"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller:
                  _emailController,
              decoration:
                  const InputDecoration(
                labelText:
                    "メールアドレス",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "パスワード",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _confirmController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "パスワード確認",
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed:
                  _loading
                      ? null
                      : _register,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text(
                      "登録",
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}