import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../services/game_service.dart';

import '../task/task_list_screen.dart';
import 'game_form_screen.dart';

import '../../utils/page_route.dart';

import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/game_card.dart';
import '../../widgets/empty_view.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final GameService _gameService = GameService();
  final TextEditingController _searchController = TextEditingController();

  String get sortLabel {
    switch (_gameService.sortType) {
      case GameSortType.name:
        return '名称順';
      case GameSortType.created:
        return '追加順';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),

      appBar: const AppHeader(selectedIndex: 1),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('ゲーム追加'),
        onPressed: () async {
          await Navigator.push(context, appRoute(const GameFormScreen()));
          setState(() {});
        },
      ),
      body: Column(
        children: [

          //==========================
          // 検索バー
          //==========================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ゲームを検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _gameService.searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _gameService.searchText = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _gameService.searchText = value),
            ),
          ),

          //==========================
          // フィルター・並び替え
          //==========================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //==========================
                // 種類
                //==========================

                Container(
                  width: 391,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('種類', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // すべて
                          FilterChip(
                            label: const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(child: Text('すべて')),
                            ),
                            selected: _gameService.typeFilter == GameTypeFilter.all,
                            onSelected: (_) => setState(() => _gameService.typeFilter = GameTypeFilter.all),
                          ),
                          // スマホ
                          FilterChip(
                            label: const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(child: Text('スマホ')),
                            ),
                            selected: _gameService.typeFilter == GameTypeFilter.smartphone,
                            onSelected: (_) => setState(() => _gameService.typeFilter = GameTypeFilter.smartphone),
                          ),
                          // PC
                          FilterChip(
                            label: const SizedBox(
                              width: 35,
                              height: 20,
                              child: Center(child: Text('PC')),
                            ),
                            selected: _gameService.typeFilter == GameTypeFilter.pc,
                            onSelected: (_) => setState(() => _gameService.typeFilter = GameTypeFilter.pc),
                          ),
                          // その他
                          FilterChip(
                            label: const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(child: Text('その他')),
                            ),
                            selected: _gameService.typeFilter == GameTypeFilter.other,
                            onSelected: (_) => setState(() => _gameService.typeFilter = GameTypeFilter.other),
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
                PopupMenuButton<GameSortType>(
                  onSelected: (value) => setState(() => _gameService.sortType = value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: GameSortType.name, child: Text('名称順')),
                    PopupMenuItem(value: GameSortType.created, child: Text('追加順')),
                  ],
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort),
                        const SizedBox(width: 6),
                        Text(sortLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: StreamBuilder<List<Game>>(
              stream: _gameService.getGames(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final games = snapshot.data!;
                if (games.isEmpty) {
                  return EmptyView(
                    icon: Icons.sports_esports,
                    title: "ゲームがありません",
                    message: "条件に一致するゲームはありません。",
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return GameCard(
                      gameName: game.name,
                      iconUrl: game.iconUrl,
                      resetHour: game.dailyResetHour,
                      description: game.description,
                      types: game.types,
                      onEdit: () async {
                        await Navigator.push(context, appRoute(GameFormScreen(game: game)));
                        setState(() {});
                      },
                      onOpenTasks: () {
                        Navigator.push(context, appRoute(TaskListScreen(game: game)));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}