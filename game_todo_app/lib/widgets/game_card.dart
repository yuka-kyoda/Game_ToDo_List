import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String gameName;
  final String iconUrl;
  final int resetHour;

  final String description;
  final List<String> types;

  static double _typeWidth(String type) {

    switch(type) {

      case "すべて":
        return 50;

      case "スマホ":
        return 50;

      case "PC":
        return 35;

      case "その他":
        return 50;

      default:
        return 50;
    }
  }

  final VoidCallback? onEdit;
  final VoidCallback? onOpenTasks;

  const GameCard({
    super.key,
    required this.gameName,
    required this.iconUrl,
    required this.resetHour,

    required this.description,
    required this.types,

    this.onEdit,
    this.onOpenTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: iconUrl.isNotEmpty
                      ? Image.network(
                          iconUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.sports_esports,
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sports_esports,
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "リセット: ${resetHour.toString().padLeft(2, '0')}:00",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),

                      if (types.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Wrap(
                            spacing: 6,
                            children: types.map(
                              (type) {
                                return FilterChip(
                                  label: SizedBox(
                                    width: _typeWidth(type),
                                    height: 20,
                                    child: Center(
                                      child: Text(type),
                                    ),
                                  ),

                                  selected: false,

                                  onSelected: (_) {},
                                );
                              },
                            ).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text("編集"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpenTasks,
                    icon: const Icon(Icons.list_alt),
                    label: const Text("タスク一覧"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}