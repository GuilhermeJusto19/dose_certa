import 'package:flutter/services.dart';

class Utils {
  /// Capitaliza apenas a primeira letra da string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palavra da string (estilo título).
  static String capitalizeTitle(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  static copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
