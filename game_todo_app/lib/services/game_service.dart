// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

import '../models/game.dart';

enum GameSortType {
  name,
  created,
}

enum GameTypeFilter {
  all,
  smartphone,
  pc,
  other,
}

class GameService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get uid =>
      _auth.currentUser!.uid;

  /// 並び替え
  GameSortType sortType =
      GameSortType.name;

  /// 検索
  String searchText = "";

  /// 種類フィルター
  GameTypeFilter typeFilter =
      GameTypeFilter.all;

  //==========================
  // ゲーム追加
  //==========================

  Future<void> addGame(
    Game game,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .add(game.toMap());
  }

  //==========================
  // ゲーム一覧取得（Stream）
  //==========================

  Stream<List<Game>> getGames() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .snapshots()
        .map((snapshot) {

          List<Game> list = snapshot.docs
              .map(
                (doc) => Game.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList();

          //==========================
          // 検索
          //==========================

          if (searchText.isNotEmpty) {
            final keyword =
                searchText.toLowerCase();

            list = list.where((game) {
              return game.name
                  .toLowerCase()
                  .contains(keyword);
            }).toList();
          }

          //==========================
          // 種類フィルター
          //==========================

          switch (typeFilter) {
            case GameTypeFilter.smartphone:
              list = list
                  .where(
                    (game) =>
                        game.types.contains("スマホ"),
                  )
                  .toList();
              break;

            case GameTypeFilter.pc:
              list = list
                  .where(
                    (game) =>
                        game.types.contains("PC"),
                  )
                  .toList();
              break;

            case GameTypeFilter.other:
              list = list
                  .where(
                    (game) =>
                        game.types.contains("その他"),
                  )
                  .toList();
              break;

            case GameTypeFilter.all:
              break;
          }

          //==========================
          // 並び替え
          //==========================

          switch (sortType) {

            case GameSortType.name:

              list.sort(
                (a, b) => a.name
                    .toLowerCase()
                    .compareTo(
                      b.name.toLowerCase(),
                    ),
              );
              break;

            case GameSortType.created:

              list.sort(
                (a, b) => b.createdAt.compareTo(
                  a.createdAt,
                ),
              );
              break;
          }

          return list;
        });
  }

  //==========================
  // ダッシュボード用ゲーム一覧取得
  //==========================

  Stream<List<Game>> getAllGames() {
    return getGames();
  }

  //==========================
  // ゲーム一覧取得（Future）
  // 繰り返しタスク更新用
  //==========================

  Future<List<Game>> getGamesList() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .get();

    return snapshot.docs
        .map(
          (doc) => Game.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  //==========================
  // ゲームIDから取得
  //==========================

  Future<Game?> getGameById(
    String gameId,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .doc(gameId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Game.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  //==========================
  // ゲーム更新
  //==========================

  Future<void> updateGame(
    Game game,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .doc(game.id)
        .update(game.toMap());
  }

  //==========================
  // ゲーム削除
  //==========================

  Future<void> deleteGame(
    String gameId,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .doc(gameId)
        .delete();
  }

  //==========================
  // アイコン画像アップロード
  //==========================

  /*
  Future<String> uploadGameIcon(File file) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("users")
        .child(uid)
        .child("game_icons")
        .child(
          "${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

    await storageRef.putFile(file);

    return await storageRef.getDownloadURL();
  }
  */
}