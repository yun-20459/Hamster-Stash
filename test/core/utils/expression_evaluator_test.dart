import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_stash/core/utils/expression_evaluator.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('given single number, '
        'when evaluated, '
        'then returns that number', () {
      expect(evaluateExpression('42'), 42.0);
    });

    test('given addition, '
        'when evaluated, '
        'then returns sum', () {
      expect(evaluateExpression('10+5'), 15.0);
    });

    test('given subtraction, '
        'when evaluated, '
        'then returns difference', () {
      expect(evaluateExpression('100\u221250'), 50.0);
    });

    test('given multiplication, '
        'when evaluated, '
        'then returns product', () {
      expect(evaluateExpression('3\u00D74'), 12.0);
    });

    test('given division, '
        'when evaluated, '
        'then returns quotient', () {
      expect(evaluateExpression('100\u00F74'), 25.0);
    });

    test('given multiplication precedence, '
        'when evaluated, '
        'then mul/div before add/sub', () {
      // 2 + 3 x 4 = 14
      expect(evaluateExpression('2+3\u00D74'), 14.0);
    });

    test('given decimal numbers, '
        'when evaluated, '
        'then handles correctly', () {
      expect(evaluateExpression('1.5+2.5'), 4.0);
    });

    test('given empty string, '
        'when evaluated, '
        'then returns 0', () {
      expect(evaluateExpression(''), 0.0);
    });

    test('given trailing operator, '
        'when evaluated, '
        'then ignores it', () {
      expect(evaluateExpression('10+'), 10.0);
    });

    test('given division by zero, '
        'when evaluated, '
        'then returns 0', () {
      expect(evaluateExpression('10\u00F70'), 0.0);
    });
  });
}
