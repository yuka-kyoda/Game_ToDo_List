import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/task.dart';

import '../services/game_service.dart';
import '../services/task_service.dart';

import '../utils/page_route.dart';

import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_game_card.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/empty_view.dart';

import 'game/game_form_screen.dart';
import 'game/game_list_screen.dart';
import 'task/task_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  final TaskService taskService =
      TaskService();

  final GameService gameService =
      GameService();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 初回チェック
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _checkRecurringTasks();
    });

    // 1分ごとに更新
    _timer = Timer.periodic(
      const Duration(
        minutes: 1,
      ),
      (_) {
        _checkRecurringTasks();
      },
    );
  }

  @override
  void dispose() {

    _timer?.cancel();

    super.dispose();
  }

  //==========================
  // 繰り返しタスクを確認
  //==========================

  Future<void> _checkRecurringTasks() async {

    try {

      final games =
          await gameService.getGamesList();

      await taskService.checkRecurringTasks(
        games,
      );

      if (mounted) {
        setState(() {});
      }

    } catch (e) {

      debugPrint(
        "繰り返しタスク更新エラー: $e",
      );

    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      endDrawer: const AppDrawer(),

      appBar: const AppHeader(
        selectedIndex: 0,
      ),

      body: StreamBuilder<List<Task>>(
        stream:
            taskService.getAllTasks(),
        builder:
            (context, taskSnapshot) {

          if (!taskSnapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final tasks =
              taskSnapshot.data!;

          final now =
              DateTime.now();

          final todayTasks =
              tasks.where((task) {

            if (task.isCompleted) {
              return false;
            }

            if (task.dueDate ==
                null) {
              return false;
            }

            return task.dueDate!.year ==
                    now.year &&
                task.dueDate!.month ==
                    now.month &&
                task.dueDate!.day ==
                    now.day;

          }).length;

          final overdueTasks =
              tasks.where((task) {

            if (task.isCompleted) {
              return false;
            }

            if (task.dueDate ==
                null) {
              return false;
            }

            return task.dueDate!
                .isBefore(now);

          }).length;

          final weekTasks =
              tasks.where((task) {

            if (task.isCompleted) {
              return false;
            }

            if (task.dueDate ==
                null) {
              return false;
            }

            final diff =
                task.dueDate!
                    .difference(now)
                    .inDays;

            return diff >= 0 &&
                diff <= 7;

          }).length;

          return StreamBuilder<
              List<Game>>(
            stream:
                gameService
                    .getAllGames(),
            builder: (
              context,
              gameSnapshot,
            ) {

              if (!gameSnapshot
                  .hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final games =
                  gameSnapshot
                      .data!;

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [

                    DashboardStatCard(
                      title:
                          "今日のタスク",
                      value:
                          "$todayTasks件",
                      icon:
                          Icons.today,
                      color:
                          Colors.orange,
                      onTap: () {

                        Navigator.push(
                          context,
                          appRoute(
                            const TaskListScreen(
                              showBackButton: true,
                              initialDateFilter:
                                  DateFilter
                                      .today,
                            ),
                          ),
                        );

                      },
                    ),

                    DashboardStatCard(
                      title:
                          "期限切れ",
                      value:
                          "$overdueTasks件",
                      icon:
                          Icons.warning,
                      color:
                          Colors.red,
                      onTap: () {

                        Navigator.push(
                          context,
                          appRoute(
                            const TaskListScreen(
                              showBackButton: true,
                              initialDateFilter:
                                  DateFilter
                                      .overdue,
                            ),
                          ),
                        );

                      },
                    ),

                    DashboardStatCard(
                      title:
                          "今週の予定",
                      value:
                          "$weekTasks件",
                      icon: Icons
                          .calendar_month,
                      color:
                          Colors.blue,
                      onTap: () {

                        Navigator.push(
                          context,
                          appRoute(
                            const TaskListScreen(
                              showBackButton: true,
                              initialDateFilter:
                                  DateFilter
                                      .thisWeek,
                            ),
                          ),
                        );

                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Text(
                      "登録ゲーム",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (games.isEmpty)

                      EmptyView(
                        icon: Icons.sports_esports,
                        title: "ゲームがありません",
                        message: "登録されているゲームはありません。",
                        buttonText: "ゲームを追加",
                        onPressed: () async {

                          await Navigator.push(
                            context,
                            appRoute(
                              const GameFormScreen(),
                            ),
                          );

                          setState(() {});
                        },
                      )

                    else

                      ...games.map(
                        (game) {

                          final count =
                              tasks
                                  .where(
                                    (task) =>
                                        task.gameId ==
                                            game.id &&
                                        !task.isCompleted,
                                  )
                                  .length;

                          return DashboardGameCard(
                            gameName:
                                game.name,
                            resetHour:
                                game.dailyResetHour,
                            taskCount:
                                count,
                            onTap: () async {

                              await Navigator.push(
                                context,
                                appRoute(
                                  TaskListScreen(
                                    game: game,
                                  ),
                                ),
                              );

                              await _checkRecurringTasks();
                            },
                          );
                        },
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