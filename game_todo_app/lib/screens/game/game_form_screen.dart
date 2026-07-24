// import 'dart:io';

// import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../services/game_service.dart';

import '../../widgets/form_text_field.dart';
import '../../widgets/primary_button.dart';

class GameFormScreen extends StatefulWidget {
  final Game? game;

  const GameFormScreen({
    super.key,
    this.game,
  });

  @override
  State<GameFormScreen> createState() =>
      _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController =
    TextEditingController();

  final List<String> _types = [];

  /*
  File? _iconFile;

  final ImagePicker _picker = ImagePicker();
  */

  int _resetHour = 4;

  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();

    if (widget.game != null) {
      _nameController.text = widget.game!.name;

      _descriptionController.text =
          widget.game!.description;

      _types.addAll(widget.game!.types);

      _resetHour = widget.game!.dailyResetHour;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Firebase Storageを使う場合
  /*
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      _iconFile = File(image.path);
    });
  }
  */

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final iconUrl = widget.game?.iconUrl ?? "";

    /*
    String iconUrl = widget.game?.iconUrl ?? "";

    if (_iconFile != null) {
      iconUrl =
          await _gameService.uploadGameIcon(_iconFile!);
    }
    */

    final game = Game(
      id: widget.game?.id ?? '',
      name: _nameController.text.trim(),
      iconUrl: iconUrl,
      dailyResetHour: _resetHour,

      createdAt:
          widget.game?.createdAt ??
          DateTime.now(),

      description:
          _descriptionController.text.trim(),

      types: List<String>.from(_types),
    );

    if (widget.game == null) {
      await _gameService.addGame(game);
    } else {
      await _gameService.updateGame(game);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _deleteGame() async {
    if (widget.game == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("確認"),
          content: const Text("このゲームを削除しますか？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("キャンセル"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("削除"),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await _gameService.deleteGame(widget.game!.id);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.game == null ? "ゲーム追加" : "ゲーム編集",
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /*
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: _iconFile != null
                      ? FileImage(_iconFile!)
                      : (widget.game?.iconUrl.isNotEmpty == true
                          ? NetworkImage(widget.game!.iconUrl)
                          : null),
                  child: (_iconFile == null &&
                          (widget.game?.iconUrl.isEmpty ?? true))
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 36,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),
              */

              FormTextField(
                controller: _nameController,
                label: "ゲーム名",
                hint: "ゲーム名を入力",
                icon: Icons.sports_esports,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "ゲーム名を入力してください";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              FormTextField(
                controller: _descriptionController,
                label: "説明",
                hint: "ゲームの説明を入力",
                icon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "種類",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              CheckboxListTile(
                title: const Text("スマホ"),
                value: _types.contains("スマホ"),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _types.add("スマホ");
                    } else {
                      _types.remove("スマホ");
                    }
                  });
                },
              ),

              CheckboxListTile(
                title: const Text("PC"),
                value: _types.contains("PC"),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _types.add("PC");
                    } else {
                      _types.remove("PC");
                    }
                  });
                },
              ),

              CheckboxListTile(
                title: const Text("その他"),
                value: _types.contains("その他"),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _types.add("その他");
                    } else {
                      _types.remove("その他");
                    }
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                value: _resetHour,
                decoration: InputDecoration(
                  labelText: "リセット時間",
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(
                  24,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text("$index時"),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _resetHour = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: "保存",
                icon: Icons.save,
                onPressed: _saveGame,
              ),

              if (widget.game != null) ...[
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("削除"),
                    onPressed: _deleteGame,
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