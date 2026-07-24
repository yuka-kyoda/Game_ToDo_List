import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  final Color priorityColor;
  final String priorityText;

  final bool isOverdue;
  final bool isToday;

  final ValueChanged<bool?>? onCompleted;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.priorityColor,
    required this.priorityText,
    required this.isOverdue,
    required this.isToday,
    this.onCompleted,
    this.onEdit,
  });

  String get dueText {
    if (task.dueDate == null) return "";

    final d = task.dueDate!;

    return
        "${d.year}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }

  String get nextResetText {
    if (task.nextReset != null) {
      final d = task.nextReset!;

      return
          "${d.year}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.day.toString().padLeft(2, '0')} "
          "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}";
    }

    if (task.dueDate == null) return "";

    final d = task.dueDate!;

    return
        "${d.year}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }

  bool get isRepeatTask =>
      task.repeatType != "なし";

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: task.isCompleted ? 0.55 : 1.0,
      child: Card(
        color: task.isCompleted
            ? Colors.grey.shade300
            : Colors.white,
        elevation: 3,
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Row(
          children: [

            // 左の優先度バー
            Container(
              width: 6,
              height: 120,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius:
                    const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft:
                      Radius.circular(14),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          //==========================
                          // タイトル
                          //==========================
                          Row(
                            children: [

                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    decoration:
                                        task.isCompleted
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                    color: isOverdue
                                        ? Colors.red
                                        : null,
                                  ),
                                ),
                              ),

                              if (isRepeatTask)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .lightBlue,
                                    borderRadius:
                                        BorderRadius.circular(
                                            6),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [

                                      const Icon(
                                        Icons.sync,
                                        color: Colors
                                            .white,
                                        size: 15,
                                      ),

                                      const SizedBox(
                                          width: 4),

                                      Text(
                                        task.repeatType,
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          if (task.description
                              .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 8,
                              ),
                              child: Text(
                                task.description,
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 12,
                          ),

                          //==========================
                          // 日付・次回リセット
                          //==========================

                          if (isRepeatTask)
                            Row(
                              children: [

                                const Icon(
                                  Icons.sync,
                                  size: 18,
                                  color: Colors.lightBlue,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    "次回リセット：$nextResetText",
                                    style: const TextStyle(
                                      color: Colors.lightBlue,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )

                          else if (task.dueDate != null)
                            Row(
                              children: [

                                Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: isOverdue
                                      ? Colors.red
                                      : isToday
                                          ? Colors.orange
                                          : Colors.grey,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    dueText,
                                    style: TextStyle(
                                      color: isOverdue
                                          ? Colors.red
                                          : isToday
                                              ? Colors.orange
                                              : Colors.grey,
                                      fontWeight: isOverdue
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),

                                if (isOverdue)
                                  Container(
                                    margin:
                                        const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(
                                              5),
                                    ),
                                    child: const Text(
                                      "期限切れ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    //==========================
                    // 右側ボタン
                    //==========================

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [

                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            ElevatedButton(
                              onPressed: () =>
                                  onCompleted?.call(
                                !task.isCompleted,
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green,
                                minimumSize:
                                    const Size(46, 46),
                                padding:
                                    EdgeInsets.zero,
                              ),
                              child: Icon(
                                task.isCompleted
                                    ? Icons.undo
                                    : Icons.check,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 6),

                            ElevatedButton(
                              onPressed: onEdit,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blue,
                                minimumSize:
                                    const Size(46, 46),
                                padding:
                                    EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            borderRadius:
                                BorderRadius.circular(
                              6,
                            ),
                          ),
                          child: Text(
                            priorityText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}