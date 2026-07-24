import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  String get uid =>
      _auth.currentUser!.uid;

  /// プロフィール作成
  Future<void> createUserProfile(
    UserProfile profile,
  ) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap());
  }

  /// プロフィール取得
  Future<UserProfile?> getUserProfile(
    String uid,
  ) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UserProfile.fromMap(
      doc.data()!,
    );
  }

  /// リアルタイム取得
  Stream<UserProfile> profileStream() {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (doc) => UserProfile.fromMap(
            doc.data()!,
          ),
        );
  }

  /// プロフィール更新
  Future<void> updateProfile(
    UserProfile profile,
  ) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  /// プロフィール画像アップロード
  Future<String> uploadAvatar(
    File image,
  ) async {
    final ref = _storage
        .ref()
        .child('profile_pics')
        .child('$uid.jpg');

    await ref.putFile(image);

    final url =
        await ref.getDownloadURL();

    await _db
        .collection('users')
        .doc(uid)
        .update({
      'avatarUrl': url,
    });

    return url;
  }

  /// 総タスク数
  Future<int> getTotalTaskCount() async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    return snapshot.docs.length;
  }

  /// 完了タスク数
  Future<int> getCompletedTaskCount() async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where(
          'isCompleted',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs.length;
  }

  /// アカウント削除
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) return;

    // タスク削除
    final tasks = await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    for (final doc in tasks.docs) {
      await doc.reference.delete();
    }

    // プロフィール画像削除
    try {
      await _storage
          .ref()
          .child('profile_pics')
          .child('$uid.jpg')
          .delete();
    } catch (_) {}

    // プロフィール削除
    await _db
        .collection('users')
        .doc(uid)
        .delete();

    // Firebase Authentication削除
    await user.delete();
  }
}