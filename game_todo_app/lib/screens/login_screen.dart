import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import '../utils/page_route.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  Future<void> _login() async {
    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ログイン成功"),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("ログイン")),
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

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _login,
              child:
                  const Text("ログイン"),
            ),

            const SizedBox(height: 16),

            TextButton(
            onPressed: () {
                Navigator.push(
                context,
                appRoute(
                  const RegisterScreen(),
                ),
                );
            },
            child: const Text(
                "アカウントをお持ちでないですか？ 登録する",
            ),
            ),
          ],
        ),
      ),
    );
  }
}