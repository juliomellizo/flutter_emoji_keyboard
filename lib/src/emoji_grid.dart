import 'package:flutter/material.dart';

/// Grid de emojis optimizado.
class EmojiGrid extends StatelessWidget {
  final List<String> emojis;
  final Function(String) onEmojiSelected;

  const EmojiGrid({
    Key? key,
    required this.emojis,
    required this.onEmojiSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 8 : 16;

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return GestureDetector(
          onTap: () => onEmojiSelected(emoji),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 24)),
          ),
        );
      },
    );
  }
}
