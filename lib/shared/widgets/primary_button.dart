import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Standard primary CTA — gold, full-width, H = 48px.
/// [enabled] fades the button when false (still tappable for demo).
/// [trailingIcon] defaults to the right-arrow; set null to hide.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.trailingIcon = 'assets/icons/base/arrowright.svg',
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1.0 : 0.45,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                SvgPicture.asset(
                  trailingIcon!,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
