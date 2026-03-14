/// Regex: pure digits (Taiwan stock codes are 4-6 digits).
final _digitOnly = RegExp(r'^\d+$');

/// Returns true if [input] looks like a Taiwan stock code
/// (pure digits, not already suffixed with .TW/.TWO).
bool isLikelyTwStock(String input) {
  return _digitOnly.hasMatch(input);
}

/// Normalizes a user-entered stock symbol:
/// - Trims whitespace and uppercases
/// - Pure digits (e.g. "2330") → appends ".TW"
/// - Already has suffix (e.g. "2330.TW") → keeps as-is
/// - Alpha or alphanumeric (e.g. "TSLA") → keeps as-is
String normalizeSymbol(String input) {
  final trimmed = input.trim().toUpperCase();
  if (trimmed.isEmpty) return '';
  if (isLikelyTwStock(trimmed)) return '$trimmed.TW';
  return trimmed;
}
