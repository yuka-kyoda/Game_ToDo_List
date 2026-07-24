import 'package:flutter/material.dart';

class GameIcon extends StatelessWidget {
  final String imageUrl;
  final double size;

  const GameIcon({
    super.key,
    required this.imageUrl,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(
          Icons.sports_esports,
          size: size * 0.6,
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage:
          NetworkImage(imageUrl),
    );
  }
}