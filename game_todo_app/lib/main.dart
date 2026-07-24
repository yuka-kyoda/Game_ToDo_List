import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 通知サービス初期化
  await NotificationService.instance.initialize();

  runApp(const GameTodoApp());
}

class GameTodoApp extends StatelessWidget {
  const GameTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameToDo',
      debugShowCheckedModeBanner: false,

      // Django版デザインを反映した共通テーマ
      theme: AppTheme.lightTheme,

      home: const AuthGate(),
    );
  }
}