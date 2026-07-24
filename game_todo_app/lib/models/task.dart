class Task {
  final String id;
  final String gameId;

  final String title;
  final String description;

  /// 締切
  final DateTime? dueDate;

  /// 優先度
  final int priority;

  /// 完了状態
  final bool isCompleted;

  /// 作成日時
  final DateTime? createdAt;

  /// 更新日時
  final DateTime? updatedAt;

  /// 完了日時
  final DateTime? completedAt;

  //==============================
  // 繰り返し設定
  //==============================

  /// 繰り返しタスクか
  final bool isRecurring;

  /// なし・毎日・毎週・毎月・カスタム
  final String repeatType;

  /// カスタム（日）
  final int repeatDays;

  /// カスタム（時間）
  final int repeatHours;

  /// 毎週（月=0～日=6）
  final int repeatWeekday;

  /// 毎月（1～31）
  final int repeatDayOfMonth;

  /// 次回更新日時
  final DateTime? nextReset;

  Task({
    required this.id,
    required this.gameId,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    required this.isCompleted,

    this.createdAt,
    this.updatedAt,
    this.completedAt,

    this.isRecurring = false,
    this.repeatType = "なし",
    this.repeatDays = 0,
    this.repeatHours = 0,
    this.repeatWeekday = 0,
    this.repeatDayOfMonth = 1,
    this.nextReset,
  });

  factory Task.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Task(
      id: id,

      gameId: data['gameId'] ?? '',

      title: data['title'] ?? '',

      description: data['description'] ?? '',

      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : null,

      priority: data['priority'] ?? 1,

      isCompleted:
          data['isCompleted'] ?? false,

      createdAt:
          data['createdAt'] != null
              ? DateTime.parse(
                  data['createdAt'],
                )
              : null,

      updatedAt:
          data['updatedAt'] != null
              ? DateTime.parse(
                  data['updatedAt'],
                )
              : null,

      completedAt:
          data['completedAt'] != null
              ? DateTime.parse(
                  data['completedAt'],
                )
              : null,

      //==============================
      // 繰り返し設定
      //==============================

      isRecurring:
          data['isRecurring'] ?? false,

      repeatType:
          data['repeatType'] ?? "なし",

      repeatDays:
          data['repeatDays'] ?? 0,

      repeatHours:
          data['repeatHours'] ?? 0,

      repeatWeekday:
          data['repeatWeekday'] ?? 0,

      repeatDayOfMonth:
          data['repeatDayOfMonth'] ?? 1,

      nextReset:
          data['nextReset'] != null
              ? DateTime.parse(
                  data['nextReset'],
                )
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,

      'title': title,

      'description': description,

      'dueDate':
          dueDate?.toIso8601String(),

      'priority': priority,

      'isCompleted': isCompleted,

      'createdAt':
          createdAt?.toIso8601String(),

      'updatedAt':
          updatedAt?.toIso8601String(),

      'completedAt':
          completedAt?.toIso8601String(),

      //==============================
      // 繰り返し設定
      //==============================

      'isRecurring': isRecurring,

      'repeatType': repeatType,

      'repeatDays': repeatDays,

      'repeatHours': repeatHours,

      'repeatWeekday': repeatWeekday,

      'repeatDayOfMonth':
          repeatDayOfMonth,

      'nextReset':
          nextReset?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? gameId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,

    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,

    bool? isRecurring,
    String? repeatType,
    int? repeatDays,
    int? repeatHours,
    int? repeatWeekday,
    int? repeatDayOfMonth,
    DateTime? nextReset,
  }) {
    return Task(
      id: id ?? this.id,

      gameId: gameId ?? this.gameId,

      title: title ?? this.title,

      description:
          description ?? this.description,

      dueDate: dueDate ?? this.dueDate,

      priority: priority ?? this.priority,

      isCompleted:
          isCompleted ?? this.isCompleted,

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,

      completedAt:
          completedAt ?? this.completedAt,

      isRecurring:
          isRecurring ?? this.isRecurring,

      repeatType:
          repeatType ?? this.repeatType,

      repeatDays:
          repeatDays ?? this.repeatDays,

      repeatHours:
          repeatHours ?? this.repeatHours,

      repeatWeekday:
          repeatWeekday ??
              this.repeatWeekday,

      repeatDayOfMonth:
          repeatDayOfMonth ??
              this.repeatDayOfMonth,

      nextReset:
          nextReset ?? this.nextReset,
    );
  }
}