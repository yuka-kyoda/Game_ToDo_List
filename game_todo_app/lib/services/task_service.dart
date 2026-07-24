import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';
import '../models/game.dart';

enum SortType {
  dueDate,
  priority,
  created,
  name,
}

enum PriorityFilter {
  all,
  high,
  medium,
  low,
}

enum DateFilter {
  all,
  today,
  overdue,
  thisWeek,
}

class TaskService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get uid =>
      _auth.currentUser!.uid;

  /// 並び替え
  SortType sortType =
      SortType.dueDate;

  /// 完了済み表示
  bool showCompleted = true;

  /// 検索
  String searchText = "";

  /// 優先度
  PriorityFilter priorityFilter =
      PriorityFilter.all;

  /// 日付
  DateFilter dateFilter =
      DateFilter.all;

  //==========================
  // タスク追加
  //==========================

  Future<void> addTask(
    Task task,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add(task.toMap());
  }

  //==========================
  // 全取得
  //==========================

  Stream<List<Task>> getAllTasks() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Task.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  //==========================
  // ゲーム別取得
  //==========================

  Stream<List<Task>> getTasksByGame(
    String gameId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where(
          'gameId',
          isEqualTo: gameId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Task.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  //==========================
  // 全タスク取得（並び替え・フィルター）
  //==========================

  Stream<List<Task>> getSortedAllTasks() {
    return getAllTasks().map((tasks) {
      List<Task> list = List.from(tasks);

      //==========================
      // 完了済み表示
      //==========================

      if (!showCompleted) {
        list = list
            .where(
              (task) => !task.isCompleted,
            )
            .toList();
      }

      //==========================
      // 検索
      //==========================

      if (searchText.isNotEmpty) {
        final keyword =
            searchText.toLowerCase();

        list = list.where((task) {
          return task.title
                  .toLowerCase()
                  .contains(keyword) ||
              task.description
                  .toLowerCase()
                  .contains(keyword);
        }).toList();
      }

      //==========================
      // 優先度フィルター
      //==========================

      switch (priorityFilter) {
        case PriorityFilter.high:
          list = list
              .where(
                (task) =>
                    task.priority == 2,
              )
              .toList();
          break;

        case PriorityFilter.medium:
          list = list
              .where(
                (task) =>
                    task.priority == 1,
              )
              .toList();
          break;

        case PriorityFilter.low:
          list = list
              .where(
                (task) =>
                    task.priority == 0,
              )
              .toList();
          break;

        case PriorityFilter.all:
          break;
      }

      //==========================
      // 日付フィルター
      //==========================

      switch (dateFilter) {
        case DateFilter.today:
          final now = DateTime.now();

          list = list.where((task) {
            if (task.isCompleted ||
                task.dueDate == null) {
              return false;
            }

            return task.dueDate!.year ==
                    now.year &&
                task.dueDate!.month ==
                    now.month &&
                task.dueDate!.day ==
                    now.day;
          }).toList();
          break;

        case DateFilter.overdue:
          final now = DateTime.now();

          list = list.where((task) {
            if (task.isCompleted ||
                task.dueDate == null) {
              return false;
            }

            return task.dueDate!
                .isBefore(now);
          }).toList();
          break;

        case DateFilter.thisWeek:
          final now = DateTime.now();

          list = list.where((task) {
            if (task.isCompleted ||
                task.dueDate == null) {
              return false;
            }

            final diff = task
                .dueDate!
                .difference(now)
                .inDays;

            return diff >= 0 &&
                diff <= 7;
          }).toList();
          break;

        case DateFilter.all:
          break;
      }

      //==========================
      // 並び替え
      //==========================

      switch (sortType) {

        case SortType.name:
          list.sort(
            (a, b) => a.title.toLowerCase().compareTo(
              b.title.toLowerCase(),
            ),
          );
          break;

        case SortType.priority:
          list.sort(
            (a, b) => b.priority.compareTo(
              a.priority,
            ),
          );
          break;

        case SortType.created:
          list.sort((a, b) {
            final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return bCreated.compareTo(aCreated);
          });
          break;

        case SortType.dueDate:
          list.sort((a, b) {
            if (a.dueDate == null &&
                b.dueDate == null) {
              return 0;
            }

            if (a.dueDate == null) {
              return 1;
            }

            if (b.dueDate == null) {
              return -1;
            }

            return a.dueDate!.compareTo(
              b.dueDate!,
            );
          });
          break;
      }

      //==========================
      // 未完了 → 完了 の順に並べる
      //==========================

      final incompleteTasks = list
          .where((task) => !task.isCompleted)
          .toList();

      final completedTasks = list
          .where((task) => task.isCompleted)
          .toList();

      list = [
        ...incompleteTasks,
        ...completedTasks,
      ];

      return list;
    });
  }

  Stream<List<Task>> getSortedTasksByGame(
    String gameId,
  ) {
    return getTasksByGame(gameId).map((tasks) {
      List<Task> list = List.from(tasks);

      if (!showCompleted) {
        list = list
            .where((task) => !task.isCompleted)
            .toList();
      }

      if (searchText.isNotEmpty) {
        final keyword = searchText.toLowerCase();

        list = list.where((task) {
          return task.title
                  .toLowerCase()
                  .contains(keyword) ||
              task.description
                  .toLowerCase()
                  .contains(keyword);
        }).toList();
      }

      switch (priorityFilter) {
        case PriorityFilter.high:
          list =
              list.where((t) => t.priority == 2).toList();
          break;

        case PriorityFilter.medium:
          list =
              list.where((t) => t.priority == 1).toList();
          break;

        case PriorityFilter.low:
          list =
              list.where((t) => t.priority == 0).toList();
          break;

        case PriorityFilter.all:
          break;
      }

      final now = DateTime.now();

      switch (dateFilter) {
        case DateFilter.today:
          list = list.where((t) {
            if (t.isCompleted ||
                t.dueDate == null) {
              return false;
            }

            return t.dueDate!.year == now.year &&
                t.dueDate!.month == now.month &&
                t.dueDate!.day == now.day;
          }).toList();
          break;

        case DateFilter.overdue:
          list = list.where((t) {
            if (t.isCompleted ||
                t.dueDate == null) {
              return false;
            }

            return t.dueDate!.isBefore(now);
          }).toList();
          break;

        case DateFilter.thisWeek:
          list = list.where((t) {
            if (t.isCompleted ||
                t.dueDate == null) {
              return false;
            }

            final diff =
                t.dueDate!
                    .difference(now)
                    .inDays;

            return diff >= 0 &&
                diff <= 7;
          }).toList();
          break;

        case DateFilter.all:
          break;
      }

      switch (sortType) {

      case SortType.name:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ),
        );
        break;

        case SortType.priority:
          list.sort(
            (a, b) =>
                b.priority.compareTo(a.priority),
          );
          break;

        case SortType.created:
          list.sort((a, b) {
            final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return bCreated.compareTo(aCreated);
          });
          break;

        case SortType.dueDate:
          list.sort((a, b) {
            if (a.dueDate == null &&
                b.dueDate == null) {
              return 0;
            }

            if (a.dueDate == null) return 1;

            if (b.dueDate == null) return -1;

            return a.dueDate!
                .compareTo(b.dueDate!);
          });
          break;
      }

      //==========================
      // 未完了 → 完了 の順に並べる
      //==========================

      final incompleteTasks = list
          .where((task) => !task.isCompleted)
          .toList();

      final completedTasks = list
          .where((task) => task.isCompleted)
          .toList();

      list = [
        ...incompleteTasks,
        ...completedTasks,
      ];

      return list;
    });
  }

  //==========================
  // 次回リセット日時を計算
  //==========================

  DateTime? calculateNextReset(
    Task task,
    Game game,
  ) {
    if (!task.isRecurring) {
      return null;
    }

    final now = DateTime.now();

    switch (task.repeatType) {

      //==========================
      // 毎日
      //==========================

      case "毎日":

        DateTime next = DateTime(
          now.year,
          now.month,
          now.day,
          game.dailyResetHour,
        );

        if (!next.isAfter(now)) {
          next = next.add(
            const Duration(days: 1),
          );
        }

        return next;

      //==========================
      // 毎週
      //==========================

      case "毎週":

        final targetWeekday =
            task.repeatWeekday + 1;

        int diff =
            targetWeekday - now.weekday;

        if (diff < 0) {
          diff += 7;
        }

        DateTime next = DateTime(
          now.year,
          now.month,
          now.day + diff,
          game.dailyResetHour,
        );

        if (!next.isAfter(now)) {
          next = next.add(
            const Duration(days: 7),
          );
        }

        return next;

      //==========================
      // 毎月
      //==========================

      case "毎月":

        DateTime next = DateTime(
          now.year,
          now.month,
          task.repeatDayOfMonth,
          game.dailyResetHour,
        );

        if (!next.isAfter(now)) {
          next = DateTime(
            now.year,
            now.month + 1,
            task.repeatDayOfMonth,
            game.dailyResetHour,
          );
        }

        return next;

      //==========================
      // カスタム
      //==========================

      case "カスタム":

        return now.add(
          Duration(
            days: task.repeatDays,
            hours: task.repeatHours,
          ),
        );

      //==========================
      // 繰り返しなし
      //==========================

      default:
        return null;
    }
  }

  //==========================
  // 繰り返しタスクをチェック
  //==========================

  Future<void> checkRecurringTasks(
    List<Game> games,
  ) async {

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    final now = DateTime.now();

    for (final doc in snapshot.docs) {

      final task = Task.fromMap(
        doc.id,
        doc.data(),
      );

      // 繰り返しタスク以外は対象外
      if (!task.isRecurring) {
        continue;
      }

      // 次回リセット日時が未設定なら対象外
      if (task.nextReset == null) {
        continue;
      }

      // まだリセット時刻ではない
      if (task.nextReset!.isAfter(now)) {
        continue;
      }

      final game = games.firstWhere(
        (g) => g.id == task.gameId,
      );

      final nextReset =
          calculateNextReset(
        task,
        game,
      );

      await doc.reference.update({

        "isCompleted": false,

        "completedAt": null,

        "updatedAt":
            DateTime.now()
                .toIso8601String(),

        "nextReset":
            nextReset
                ?.toIso8601String(),

      });
    }
  }

  //==========================
  // 更新
  //==========================

  Future<void> updateTask(
    Task task,
  ) async {

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  //==========================
  // 削除
  //==========================

  Future<void> deleteTask(
    String taskId,
  ) async {

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  //==========================
  // 完了切替
  //==========================

  Future<void> toggleCompleted(
    Task task,
    Game game,
  ) async {

    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id);

    final completed =
        !task.isCompleted;

    DateTime? nextReset =
        task.nextReset;

    DateTime? completedAt;

    if (completed) {

      completedAt = DateTime.now();

      // 繰り返しタスクなら次回リセット日時を更新
      if (task.isRecurring) {

        nextReset =
            calculateNextReset(
          task,
          game,
        );
      }

    } else {

      completedAt = null;

    }

    await doc.update({

      "isCompleted": completed,

      "completedAt":
          completedAt
              ?.toIso8601String(),

      "nextReset":
          nextReset
              ?.toIso8601String(),

      "updatedAt":
          DateTime.now()
              .toIso8601String(),

    });
  }
}