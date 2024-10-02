// flutter_emoji_keyboard/lib/utils/emoji_utils.dart
import 'dart:math';

class EmojiUtils {
  /// Extrae solo los emojis (el primer elemento) de una lista dada.
  static List<String> extractEmojis(List emojiList) {
    List<String> onlyEmojis = [];
    for (var emojiData in emojiList) {
      if (emojiData is List && emojiData.isNotEmpty && emojiData[0] is String) {
        onlyEmojis.add(emojiData[0]);
      }
    }
    return onlyEmojis;
  }

  /// Genera una lista de 16 emojis aleatorios a partir de las categorías proporcionadas.
  static List<String> generateRandomEmojis({
    required List smileys,
    required List animals,
    required List foods,
    required List activities,
    required List travel,
    required List objects,
    required List symbols,
    required List flags,
  }) {
    List<String> allEmojis = [];

    // Extraer solo los emojis de cada lista usando `extractEmojis`.
    allEmojis.addAll(extractEmojis(smileys));
    allEmojis.addAll(extractEmojis(animals));
    allEmojis.addAll(extractEmojis(foods));
    allEmojis.addAll(extractEmojis(activities));
    allEmojis.addAll(extractEmojis(travel));
    allEmojis.addAll(extractEmojis(objects));
    allEmojis.addAll(extractEmojis(symbols));
    allEmojis.addAll(extractEmojis(flags));

    // Elimina duplicados si es necesario.
    allEmojis = allEmojis.toSet().toList();

    // Verifica que hay suficientes emojis.
    if (allEmojis.length <= 16) {
      return List<String>.from(allEmojis);
    } else {
      // Selecciona 16 emojis aleatorios sin repetición.
      final random = Random();
      List<String> randomEmojisList = [];

      // Utiliza un conjunto para evitar selecciones duplicadas.
      Set<int> selectedIndices = {};

      while (randomEmojisList.length < 16) {
        int index = random.nextInt(allEmojis.length);
        if (!selectedIndices.contains(index)) {
          selectedIndices.add(index);
          randomEmojisList.add(allEmojis[index]);
        }
      }

      return randomEmojisList;
    }
  }
}
