import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/dashboard_screen.dart';
import '../screens/game/game_list_screen.dart';
import '../screens/task/task_list_screen.dart';
import '../screens/profile/profile_screen.dart';

import '../utils/page_route.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // ヘッダー（AppBarと高さを合わせる）
          Container(
            height: 56,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: const Text(
              "GameToDo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("ダッシュボード"),
            onTap: (){
              Navigator.pushReplacement(
                context,
                appRoute(
                  const DashboardScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.games),
            title: const Text("ゲーム一覧"),
            onTap: (){
              Navigator.pushReplacement(
                context,
                appRoute(
                  GameListScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.task),
            title: const Text("タスク一覧"),
            onTap: (){
              Navigator.pushReplacement(
                context,
                appRoute(
                  const TaskListScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("プロフィール"),
            onTap: (){
              Navigator.push(
                context,
                appRoute(
                  ProfileScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("ログアウト"),
            onTap: () async {

              Navigator.pop(context);

              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("確認"),

                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        "ログアウトしますか？",
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            "ログアウト",
                          ),
                          onPressed: () async {

                            Navigator.pop(context);

                            await FirebaseAuth
                                .instance
                                .signOut();
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: const Text(
                            "キャンセル",
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}