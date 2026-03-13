import 'package:flutter/material.dart';

/// Custom number keypad with digits, decimal, and
/// arithmetic operators for the transaction form.
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({required this.onInput, super.key});

  final ValueChanged<String> onInput;

  static const _operators = ['+', '\u2212', '\u00D7', '\u00F7'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Operator row
        Row(
          children: _operators
              .map(
                (op) => _KeypadButton(
                  label: op,
                  onTap: () => onInput(op),
                  textColor: theme.colorScheme.primary,
                ),
              )
              .toList(),
        ),
        // Digit rows
        for (final row in const [
          ['7', '8', '9'],
          ['4', '5', '6'],
          ['1', '2', '3'],
        ])
          Row(
            children: row
                .map((d) => _KeypadButton(label: d, onTap: () => onInput(d)))
                .toList(),
          ),
        // Bottom row: ".", "0", backspace
        Row(
          children: [
            _KeypadButton(label: '.', onTap: () => onInput('.')),
            _KeypadButton(label: '0', onTap: () => onInput('0')),
            _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () => onInput('backspace'),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.onTap,
    this.label,
    this.icon,
    this.textColor,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 24)
                : Text(
                    label!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
