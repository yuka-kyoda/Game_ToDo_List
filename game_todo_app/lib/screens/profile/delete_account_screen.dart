import 'package:flutter/material.dart';

import '../../services/user_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends State<DeleteAccountScreen> {
  final UserService _userService =
      UserService();

  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _userService.deleteAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("アカウントを削除しました"),
        ),
      );

      // AuthGateが自動でLoginScreenへ戻してくれる
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "削除に失敗しました\n$e",
          ),
        ),
      );

      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("アカウント削除"),
        content: const Text(
          "アカウントを削除すると\n"
          "すべてのゲーム・タスク・プロフィールが削除されます。\n\n"
          "この操作は元に戻せません。",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("キャンセル"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("削除する"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("アカウント削除"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 80,
            ),

            const SizedBox(height: 24),

            const Text(
              "アカウントを削除します",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "アカウントを削除すると、以下のデータはすべて削除されます。",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding:
                    EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text("・プロフィール"),
                    Text("・ゲーム一覧"),
                    Text("・タスク"),
                    Text("・Firebaseアカウント"),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : _showDeleteDialog,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),
                child: _isDeleting
                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )
                    : const Text(
                        "アカウントを削除",
                      ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isDeleting
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                        );
                      },
                child: const Text("キャンセル"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}