import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/notification_service.dart';

import '../../widgets/form_text_field.dart';
import '../../widgets/primary_button.dart';

class TaskFormScreen extends StatefulWidget {
  final Game game;
  final Task? task;

  const TaskFormScreen({
    super.key,
    required this.game,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() =>
      _TaskFormScreenState();
}

class _TaskFormScreenState
    extends State<TaskFormScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final TaskService _taskService =
      TaskService();

  bool _isCompleted = false;

  /// 締切
  DateTime? _dueDate;

  /// 開始日時（繰り返し基準）
  DateTime? _startDate;

  /// 締切あり・なし
  bool _hasDueDate = true;

  /// 優先度
  int _priority = 1;

  /// 繰り返し
  String _repeatType = "なし";

  /// カスタム（日）
  int _repeatDays = 0;

  /// カスタム（時間）
  int _repeatHours = 0;

  /// 毎週（月=0～日=6）
  int _repeatWeekday = 0;

  /// 毎月
  int _repeatDayOfMonth = 1;

  final List<String> _weekdays = const [
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日",
    "日曜日",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final task = widget.task!;

      _titleController.text =
          task.title;

      _descriptionController.text =
          task.description;

      _isCompleted =
          task.isCompleted;

      _priority =
          task.priority;

      _repeatType =
          task.repeatType;

      _repeatDays =
          task.repeatDays;

      _repeatHours =
          task.repeatHours;

      _repeatWeekday =
          task.repeatWeekday;

      _repeatDayOfMonth =
          task.repeatDayOfMonth;

      _dueDate =
          task.dueDate;

      _hasDueDate =
          task.dueDate != null;

      // 次回リセット日時
      _startDate =
          task.nextReset;
    } else {
      _startDate =
          DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _dueDate ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    setState(() {
      _hasDueDate = true;

      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _startDate ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    setState(() {
      _startDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final now = DateTime.now();

    Task task;

    task = Task(
      id: widget.task?.id ?? '',
      gameId: widget.game.id,

      title:
          _titleController.text.trim(),

      description:
          _descriptionController.text
              .trim(),

      dueDate:
          _hasDueDate ? _dueDate : null,

      priority: _priority,

      isCompleted: _isCompleted,

      createdAt:
          widget.task?.createdAt ?? now,

      updatedAt: now,

      completedAt: _isCompleted
          ? (widget.task?.completedAt ??
              now)
          : null,

      isRecurring:
          _repeatType != "なし",

      repeatType: _repeatType,

      repeatDays: _repeatDays,

      repeatHours: _repeatHours,

      repeatWeekday:
          _repeatWeekday,

      repeatDayOfMonth:
          _repeatDayOfMonth,

      nextReset: null,
    );

    if (task.isRecurring) {
      task = task.copyWith(
        nextReset: _taskService.calculateNextReset(
          task,
          widget.game,
        ),
      );
    }

    final isNew =
        widget.task == null;

    if (isNew) {
      await _taskService.addTask(task);

      await NotificationService.instance
          .showNotification(
        title: "タスクを追加しました",
        body: task.title,
      );
    } else {
      await _taskService
          .updateTask(task);

      await NotificationService.instance
          .showNotification(
        title: "タスクを更新しました",
        body: task.title,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {

    if (widget.task == null) return;

    await _taskService.deleteTask(
      widget.task!.id,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null
              ? "タスク追加"
              : "タスク編集",
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [

              FormTextField(
                controller:
                    _titleController,
                label: "タイトル",
                hint: "タイトルを入力",
                icon: Icons.title,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return "タイトルを入力してください";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              FormTextField(
                controller:
                    _descriptionController,
                label: "説明",
                hint: "説明を入力",
                icon:
                    Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _priority,
                decoration:
                    const InputDecoration(
                  labelText: "優先度",
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 2,
                    child: Text("高"),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("中"),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text("低"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _repeatType,
                decoration:
                    const InputDecoration(
                  labelText: "繰り返し",
                  border:
                      OutlineInputBorder(),
                ),
                items: const [

                  DropdownMenuItem(
                    value: "なし",
                    child: Text("なし"),
                  ),

                  DropdownMenuItem(
                    value: "毎日",
                    child: Text("毎日"),
                  ),

                  DropdownMenuItem(
                    value: "毎週",
                    child: Text("毎週"),
                  ),

                  DropdownMenuItem(
                    value: "毎月",
                    child: Text("毎月"),
                  ),

                  DropdownMenuItem(
                    value: "カスタム",
                    child: Text("カスタム"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _repeatType = value!;
                  });
                },
              ),

              if (_repeatType == "毎週") ...[
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _repeatWeekday,
                  decoration:
                      const InputDecoration(
                    labelText: "曜日",
                    border:
                        OutlineInputBorder(),
                  ),
                  items:
                      List.generate(
                    7,
                    (index) =>
                        DropdownMenuItem(
                      value: index,
                      child: Text(
                        _weekdays[index],
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _repeatWeekday =
                          value!;
                    });
                  },
                ),
              ],

              if (_repeatType == "毎月") ...[
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value:
                      _repeatDayOfMonth,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "毎月の日付",
                    border:
                        OutlineInputBorder(),
                  ),
                  items:
                      List.generate(
                    31,
                    (index) =>
                        DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        "${index + 1}日",
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _repeatDayOfMonth =
                          value!;
                    });
                  },
                ),
              ],

              if (_repeatType ==
                  "カスタム") ...[
                const SizedBox(height: 16),

                Row(
                  children: [

                    Expanded(
                      child:
                          TextFormField(
                        initialValue:
                            _repeatDays
                                .toString(),
                        keyboardType:
                            TextInputType
                                .number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              "日",
                          border:
                              OutlineInputBorder(),
                        ),
                        onChanged: (
                          value,
                        ) {
                          _repeatDays =
                              int.tryParse(
                                    value,
                                  ) ??
                                  0;
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          TextFormField(
                        initialValue:
                            _repeatHours
                                .toString(),
                        keyboardType:
                            TextInputType
                                .number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              "時間",
                          border:
                              OutlineInputBorder(),
                        ),
                        onChanged: (
                          value,
                        ) {
                          _repeatHours =
                              int.tryParse(
                                    value,
                                  ) ??
                                  0;
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                title: Text(
                  _startDate == null
                      ? "次回リセット日時"
                      : "次回リセット日時 : "
                          "${_startDate!.year}/"
                          "${_startDate!.month.toString().padLeft(2, '0')}/"
                          "${_startDate!.day.toString().padLeft(2, '0')} "
                          "${_startDate!.hour.toString().padLeft(2, '0')}:"
                          "${_startDate!.minute.toString().padLeft(2, '0')}",
                ),
                leading: const Icon(
                  Icons.schedule,
                ),
                trailing: const Icon(
                  Icons.edit_calendar,
                ),
                onTap: _selectStartDate,
              ),

              const Divider(),

              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                title: Text(
                  !_hasDueDate
                      ? "締切なし"
                      : _dueDate == null
                          ? "締切を設定"
                          : "締切 : "
                              "${_dueDate!.year}/"
                              "${_dueDate!.month.toString().padLeft(2, '0')}/"
                              "${_dueDate!.day.toString().padLeft(2, '0')} "
                              "${_dueDate!.hour.toString().padLeft(2, '0')}:"
                              "${_dueDate!.minute.toString().padLeft(2, '0')}",
                ),
                leading: const Icon(
                  Icons.calendar_today,
                ),
                trailing: IconButton(
                  icon: Icon(
                    _hasDueDate
                        ? Icons.close
                        : Icons.add,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_hasDueDate) {
                        _hasDueDate = false;
                        _dueDate = null;
                      } else {
                        _selectDueDate();
                      }
                    });
                  },
                ),
                onTap: _hasDueDate
                    ? _selectDueDate
                    : null,
              ),

              if (widget.task != null)
                CheckboxListTile(
                  title:
                      const Text("完了"),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted =
                          value ?? false;
                    });
                  },
                ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: "保存",
                icon: Icons.save,
                onPressed: _saveTask,
              ),

              if (widget.task != null) ...[
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                    ),
                    icon: const Icon(
                      Icons.delete,
                    ),
                    label: const Text(
                      "削除",
                    ),
                    onPressed:
                        _deleteTask,
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}