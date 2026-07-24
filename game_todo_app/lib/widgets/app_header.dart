import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/dashboard_screen.dart';
import '../screens/game/game_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/task/task_list_screen.dart';
import '../utils/page_route.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedIndex;

  const AppHeader({
    super.key,
    required this.selectedIndex,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < 600;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24,

      // PC版
      title: isMobile
          ? const Text(
              "GameToDo",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )

          : Row(
              children: [
                const Text(
                  "GameToDo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 40),

                _HeaderButton(
                  title: "ダッシュボード",
                  selected: selectedIndex == 0,
                  onTap: () {
                    if (selectedIndex == 0) return;

                    Navigator.pushReplacement(
                      context,
                      appRoute(
                        const DashboardScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 20),

                _HeaderButton(
                  title: "ゲーム一覧",
                  selected: selectedIndex == 1,
                  onTap: () {
                    if (selectedIndex == 1) return;

                    Navigator.pushReplacement(
                      context,
                      appRoute(
                        GameListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 20),

                _HeaderButton(
                  title: "タスク一覧",
                  selected: selectedIndex == 2,
                  onTap: () {
                    if (selectedIndex == 2) return;

                    Navigator.pushReplacement(
                      context,
                      appRoute(
                        const TaskListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

      // 右側
      actions: [

        // PC版プロフィール
        if (!isMobile)
          IconButton(
            tooltip: "プロフィール",
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                appRoute(
                  ProfileScreen(),
                ),
              );
            },
          ),

        // PC版ログアウト
        if (!isMobile)
          IconButton(
            tooltip: "ログアウト",
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              _showLogoutDialog(context);
            },
          ),

        // スマホ版ハンバーガー
        if (isMobile)
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context)
                      .openEndDrawer();
                },
              );
            },
          ),
      ],
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
        title: const Text("確認"),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            const Text(
              "ログアウトしますか？",
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  await FirebaseAuth
                      .instance
                      .signOut();
                },
                child:
                    const Text("ログアウト"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    const Text("キャンセル"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeaderButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
            color: selected
                ? Colors.white
                : Colors.white70,
          ),
        ),
      ),
    );
  }
}