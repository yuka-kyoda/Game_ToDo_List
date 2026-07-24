import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),

      content: Text(message),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("キャンセル"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);

            if (onConfirm != null) {
              onConfirm!();
            }
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}