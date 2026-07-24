import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String name;
  final String iconUrl;

  /// デイリーリセット時間（0～23時）
  final int dailyResetHour;

  final DateTime createdAt;

  final String description;

  /// スマホ・PC・その他
  final List<String> types;

  const Game({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.dailyResetHour = 4,
    required this.createdAt,
    this.description = '',
    this.types = const [],
  });

  factory Game.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Game(
      id: id,
      name: data['name'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      dailyResetHour: (data['dailyResetHour'] ?? 4) as int,

      createdAt:
          data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(
                  data['createdAt'] ??
                      DateTime.now().toIso8601String(),
                ),

      description:
          data['description'] ?? '',

      types: List<String>.from(
        data['types'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'dailyResetHour': dailyResetHour,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'types': types,
    };
  }

  Game copyWith({
    String? id,
    String? name,
    String? iconUrl,
    int? dailyResetHour,
    DateTime? createdAt,
    String? description,
    List<String>? types,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      dailyResetHour:
          dailyResetHour ?? this.dailyResetHour,
      createdAt:
          createdAt ?? this.createdAt,
      description:
          description ?? this.description,
      types: types ?? this.types,
    );
  }
}