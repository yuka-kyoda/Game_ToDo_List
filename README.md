# 開発環境

## 実行手順

**以下のコードを実行**

    //フォルダへ移動
    cd game_todo_app

    //開始時
    flutter clean                                    
    flutter pub get
    flutter run -d chrome

## 終了手順

**control + C**　or　**ターミナルの強制終了**

# 本番環境

## 更新手順

**以下のコードを実行**

    flutter build web --base-href "/~yuka/game_todo_flutter/"

**Cyberduckに以下のフォルダの中身をgame_todo_flutterにアップロード**

    game_todo_flutter/game_todo_app/build/web

**URL**
https://gms.gdl.jp/~yuka/game_todo_flutter/