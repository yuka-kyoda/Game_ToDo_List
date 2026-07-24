import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';

import '../../utils/page_route.dart';

import 'edit_profile_screen.dart';
import 'delete_account_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("プロフィール"),
      ),
      body: StreamBuilder<UserProfile>(
        stream: _userService.profileStream(),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final profile = profileSnapshot.data!;

          return StreamBuilder(
            stream: _taskService.getAllTasks(),
            builder: (context, taskSnapshot) {
              if (!taskSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final tasks = taskSnapshot.data!;

              final completed =
                  tasks.where((e) => e.isCompleted).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profile.avatarUrl.isNotEmpty
                          ? NetworkImage(profile.avatarUrl)
                          : null,
                      child: profile.avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 60,
                            )
                          : null,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Card(
                      child: ListTile(
                        title: const Text("自己紹介"),
                        subtitle: Text(
                          profile.bio.isEmpty
                              ? "自己紹介はありません"
                              : profile.bio,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Card(
                      child: ListTile(
                        title: const Text("総タスク数"),
                        trailing: Text(
                          "${tasks.length}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Card(
                      child: ListTile(
                        title: const Text("完了タスク数"),
                        trailing: Text(
                          "$completed",
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text("プロフィール編集"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            appRoute(
                              const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        child: const Text("アカウント削除"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            appRoute(
                              const DeleteAccountScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}