import 'package:flutter/material.dart';

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
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 24,

      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

          Expanded(
            child: Row(
              children: [
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
          ),

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
        ],
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Center(
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
        ),
      ),
    );
  }
}