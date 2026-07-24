class UserProfile {
  final String uid;

  final String username;

  final String email;

  final String bio;

  /// 生年月日
  final DateTime? birthDate;

  /// Firebase StorageのURL
  final String avatarUrl;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.bio = '',
    this.birthDate,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'bio': bio,
      'birthDate': birthDate?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserProfile(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'])
          : null,
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }

  UserProfile copyWith({
    String? uid,
    String? username,
    String? email,
    String? bio,
    DateTime? birthDate,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}