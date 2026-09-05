class Helpers {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatId(int id) {
    return '#${id.toString().padLeft(3, '0')}';
  }

  static String formatHeight(int height) {
    return '${height / 10} m';
  }

  static String formatWeight(int weight) {
    return '${weight / 10} kg';
  }

  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }
}