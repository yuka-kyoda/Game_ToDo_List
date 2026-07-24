import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../models/task.dart';

import '../../services/game_service.dart';
import '../../services/task_service.dart';

import '../../utils/page_route.dart';

import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_view.dart';

import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final Game? game;

  final bool showBackButton;

  // ダッシュボードから開いたときの日付フィルター
  final DateFilter initialDateFilter;

  const TaskListScreen({
    super.key,
    this.game,
    this.showBackButton = false,
    this.initialDateFilter = DateFilter.all,
  });

  @override
  State<TaskListScreen> createState() =>
      _TaskListScreenState();
}

class _TaskListScreenState
    extends State<TaskListScreen> {
  final TaskService taskService =
      TaskService();

  final GameService _gameService =
      GameService();

  Timer? _timer;

  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    taskService.dateFilter =
        widget.initialDateFilter;

    // 初回チェック
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _checkRecurringTasks();
    });

    // 1分ごとに繰り返しタスクを確認
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        if (!mounted) return;

        await _checkRecurringTasks();
      },
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _priorityText(int priority) {
    switch (priority) {
      case 2:
        return "高";
      case 1:
        return "中";
      default:
        return "低";
    }
  }

  bool _isOverdue(Task task) {
    if (task.dueDate == null ||
        task.isCompleted) {
      return false;
    }

    return task.dueDate!
        .isBefore(DateTime.now());
  }

  bool _isToday(Task task) {
    if (task.dueDate == null ||
        task.isCompleted) {
      return false;
    }

    final now = DateTime.now();

    return task.dueDate!.year ==
            now.year &&
        task.dueDate!.month ==
            now.month &&
        task.dueDate!.day ==
            now.day;
  }

  @override
  void dispose() {

    _timer?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  String get sortLabel {
    switch (taskService.sortType) {
      case SortType.name:
        return "名称順";
      
      case SortType.dueDate:
        return "締切順";

      case SortType.priority:
        return "優先度順";

      case SortType.created:
        return "追加順";
    }
  }

  //==========================
  // 繰り返しタスクをチェック
  //==========================
  Future<void> _checkRecurringTasks() async {

    try {

      final games =
          await _gameService.getGamesList();

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
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),

      appBar: widget.showBackButton
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text("タスク一覧"),
            )
          : widget.game == null
              ? const AppHeader(
                  selectedIndex: 2,
                )
              : AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(widget.game!.name),
                ),

      body: Column(
        children: [

          // 完了済み表示
          SwitchListTile(
            title: const Text("完了済みも表示"),
            value: taskService.showCompleted,
            onChanged: (value) {
              setState(() {
                taskService.showCompleted = value;
              });
            },
          ),

          // 検索バー
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "タスクを検索",
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    taskService.searchText.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.clear,
                            ),
                            onPressed: () {
                              _searchController
                                  .clear();

                              setState(() {
                                taskService.searchText =
                                    "";
                              });
                            },
                          ),
                border:
                    const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  taskService.searchText =
                      value;
                });
              },
            ),
          ),

          // フィルター・並び替え
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //==========================
                // 優先度
                //==========================

                Container(
                  width: 316,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "優先度",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [

                          FilterChip(
                            label: const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(
                                child: Text("すべて"),
                              ),
                            ),
                            selected:
                                taskService.priorityFilter ==
                                    PriorityFilter.all,
                            onSelected: (_) {
                              setState(() {
                                taskService.priorityFilter =
                                    PriorityFilter.all;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: Text("高"),
                              ),
                            ),
                            selected:
                                taskService.priorityFilter ==
                                    PriorityFilter.high,
                            selectedColor:
                                Colors.red.shade200,
                            onSelected: (_) {
                              setState(() {
                                taskService.priorityFilter =
                                    PriorityFilter.high;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: Text("中"),
                              ),
                            ),
                            selected:
                                taskService.priorityFilter ==
                                    PriorityFilter.medium,
                            selectedColor:
                                Colors.orange.shade200,
                            onSelected: (_) {
                              setState(() {
                                taskService.priorityFilter =
                                    PriorityFilter.medium;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: Text("低"),
                              ),
                            ),
                            selected:
                                taskService.priorityFilter ==
                                    PriorityFilter.low,
                            selectedColor:
                                Colors.green.shade200,
                            onSelected: (_) {
                              setState(() {
                                taskService.priorityFilter =
                                    PriorityFilter.low;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                //==========================
                // 日付
                //==========================

                Container(
                  width: 391,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "日付",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [

                          FilterChip(
                            label: const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(
                                child: Text("すべて"),
                              ),
                            ),
                            selected:
                                taskService.dateFilter ==
                                    DateFilter.all,
                            onSelected: (_) {
                              setState(() {
                                taskService.dateFilter =
                                    DateFilter.all;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 35,
                              height: 20,
                              child: Center(
                                child: Text("今日"),
                              ),
                            ),
                            selected:
                                taskService.dateFilter ==
                                    DateFilter.today,
                            onSelected: (_) {
                              setState(() {
                                taskService.dateFilter =
                                    DateFilter.today;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 65,
                              height: 20,
                              child: Center(
                                child: Text("期限切れ"),
                              ),
                            ),
                            selected:
                                taskService.dateFilter ==
                                    DateFilter.overdue,
                            onSelected: (_) {
                              setState(() {
                                taskService.dateFilter =
                                    DateFilter.overdue;
                              });
                            },
                          ),

                          FilterChip(
                            label: const SizedBox(
                              width: 35,
                              height: 20,
                              child: Center(
                                child: Text("今週"),
                              ),
                            ),
                            selected:
                                taskService.dateFilter ==
                                    DateFilter.thisWeek,
                            onSelected: (_) {
                              setState(() {
                                taskService.dateFilter =
                                    DateFilter.thisWeek;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                //==========================
                // 並び替え
                //==========================
                PopupMenuButton<SortType>(
                  onSelected: (value) {
                    setState(() {
                      taskService.sortType = value;
                    });
                  },
                  itemBuilder: (context) => const [

                    PopupMenuItem(
                      value: SortType.name,
                      child: Text("名称順"),
                    ),

                    PopupMenuItem(
                      value: SortType.dueDate,
                      child: Text("締切順"),
                    ),

                    PopupMenuItem(
                      value: SortType.priority,
                      child: Text("優先度順"),
                    ),

                    PopupMenuItem(
                      value: SortType.created,
                      child: Text("追加順"),
                    ),
                  ],
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Icon(Icons.sort),

                        const SizedBox(width: 6),

                        Text(
                          sortLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 4),

                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: widget.game != null
                  ? taskService.getSortedTasksByGame(
                      widget.game!.id,
                    )
                  : taskService.getSortedAllTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final tasks = snapshot.data!;

                if (tasks.isEmpty) {
                  return EmptyView(
                    icon: Icons.task_alt,
                    title: "タスクがありません",
                    message:
                        "条件に一致するタスクはありません。",
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  itemBuilder:
                      (context, index) {
                    final task =
                        tasks[index];

                    return TaskCard(
                      task: task,
                      priorityColor:
                          _priorityColor(
                        task.priority,
                      ),
                      priorityText:
                          _priorityText(
                        task.priority,
                      ),
                      isOverdue:
                          _isOverdue(task),
                      isToday:
                          _isToday(task),

                      onCompleted: (_) async {

                        final game = await _gameService.getGameById(
                          task.gameId,
                        );

                        if (game == null) return;

                        await taskService.toggleCompleted(
                          task,
                          game,
                        );

                        await _checkRecurringTasks();
                      },

                      onEdit: () async {

                        final game =
                            widget.game ??
                            await _gameService.getGameById(
                              task.gameId,
                            );

                        if (game == null) return;

                        await Navigator.push(
                          context,
                          appRoute(
                            TaskFormScreen(
                              game: game,
                              task: task,
                            ),
                          ),
                        );

                        await _checkRecurringTasks();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          widget.game == null
              ? null
              : FloatingActionButton.extended(
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    "タスク追加",
                  ),
                  onPressed: () async {

                    await Navigator.push(
                      context,
                      appRoute(
                        TaskFormScreen(
                          game: widget.game!,
                        ),
                      ),
                    );

                    await _checkRecurringTasks();
                  },
                ),
    );
  }
}