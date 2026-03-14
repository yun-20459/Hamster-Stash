/// Evaluates a simple arithmetic expression string with
/// operator precedence (multiply/divide before add/subtract).
///
/// Supports: + − (U+2212) × (U+00D7) ÷ (U+00F7)
/// Returns 0.0 for empty or invalid expressions.
double evaluateExpression(String expr) {
  if (expr.isEmpty) return 0;

  final tokens = _tokenize(expr);
  if (tokens.isEmpty) return 0;

  return _evaluate(tokens);
}

List<String> _tokenize(String expr) {
  final tokens = <String>[];
  final buf = StringBuffer();

  for (final ch in expr.split('')) {
    if (_isOperator(ch)) {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
      tokens.add(ch);
    } else {
      buf.write(ch);
    }
  }
  if (buf.isNotEmpty) tokens.add(buf.toString());
  return tokens;
}

bool _isOperator(String ch) {
  return ch == '+' || ch == '\u2212' || ch == '\u00D7' || ch == '\u00F7';
}

double _evaluate(List<String> tokens) {
  // Phase 1: handle × and ÷
  final simplified = <String>[];
  var i = 0;
  while (i < tokens.length) {
    final token = tokens[i];
    if (i + 2 <= tokens.length &&
        simplified.isNotEmpty &&
        (token == '\u00D7' || token == '\u00F7')) {
      var left = double.tryParse(simplified.removeLast()) ?? 0;
      var op = token;
      var rightIdx = i + 1;
      while (rightIdx < tokens.length) {
        final right = double.tryParse(tokens[rightIdx]) ?? 0;
        if (op == '\u00D7') {
          left = left * right;
        } else {
          left = right == 0 ? 0 : left / right;
        }
        if (rightIdx + 1 < tokens.length &&
            (tokens[rightIdx + 1] == '\u00D7' ||
                tokens[rightIdx + 1] == '\u00F7')) {
          op = tokens[rightIdx + 1];
          rightIdx += 2;
        } else {
          rightIdx++;
          break;
        }
      }
      simplified.add(left.toString());
      i = rightIdx;
    } else {
      simplified.add(token);
      i++;
    }
  }

  // Phase 2: handle + and −
  if (simplified.isEmpty) return 0;
  var result = double.tryParse(simplified[0]) ?? 0.0;
  var j = 1;
  while (j + 1 < simplified.length) {
    final op = simplified[j];
    final right = double.tryParse(simplified[j + 1]) ?? 0;
    if (op == '+') {
      result += right;
    } else if (op == '\u2212') {
      result -= right;
    }
    j += 2;
  }
  return result;
}
