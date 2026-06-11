import 'package:flutter/material.dart';

/// Gold full-width CTA used across onboarding and forms,
/// with the trailing chevron from the Figma design.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingChevron = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool trailingChevron;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (trailingChevron) ...const [
            SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 22),
          ],
        ],
      ),
    );
  }
}
