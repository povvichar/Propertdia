import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../utils/format.dart';
import 'bank_select.dart';
import 'primary_button.dart';

/// Shows a KHQR payment bottom sheet. Calls [onSuccess] after mock
/// verification completes, then closes itself.
void showPaymentSheet(
  BuildContext context, {
  required BankOption bank,
  required int amountUsd,
  required VoidCallback onSuccess,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _PaymentSheet(
      bank: bank,
      amountUsd: amountUsd,
      onSuccess: onSuccess,
    ),
  );
}

// ── Sheet widget ────────────────────────────────────────────────────────────

enum _State { idle, processing }

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({
    required this.bank,
    required this.amountUsd,
    required this.onSuccess,
  });

  final BankOption bank;
  final int amountUsd;
  final VoidCallback onSuccess;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  _State _state = _State.idle;

  Future<void> _pay() async {
    setState(() => _state = _State.processing);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    widget.onSuccess();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: _state == _State.processing ? _buildProcessing() : _buildIdle(),
    );
  }

  Widget _buildIdle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 20),
        const Text(
          'Complete payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        // Amount + bank pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.bank.logoBg,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.bank.logoBg == Colors.white
                      ? Border.all(color: AppColors.border)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: SvgPicture.asset(
                    widget.bank.logoAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.bank.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                usd(widget.amountUsd),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // KHQR card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 188,
                height: 188,
                child: CustomPaint(
                  painter: _MockQrPainter(
                    seed: widget.amountUsd ^ widget.bank.id.hashCode,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002B6E),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'KHQR',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Cambodia National QR',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan with ${widget.bank.name} or any KHQR-enabled app',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Open ${widget.bank.name}',
          trailingIcon: null,
          onPressed: _pay,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pay,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "I've completed the payment",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing() {
    return SizedBox(
      height: 260,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _handle(),
          const Spacer(),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'Verifying payment…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Do not close this screen',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _handle() => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

// ── Mock QR painter ─────────────────────────────────────────────────────────

class _MockQrPainter extends CustomPainter {
  const _MockQrPainter({required this.seed});

  final int seed;

  static const _n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;

    canvas.drawRect(Offset.zero & size, white);

    // Seeded data modules
    final rng = Random(seed);
    for (var r = 0; r < _n; r++) {
      for (var c = 0; c < _n; c++) {
        if (_inFinder(r, c) || _isTiming(r, c)) continue;
        if (rng.nextBool()) _module(canvas, dark, r, c, cell);
      }
    }

    // Finder patterns: top-left, top-right, bottom-left
    _finder(canvas, 0, 0, cell);
    _finder(canvas, 0, _n - 7, cell);
    _finder(canvas, _n - 7, 0, cell);

    // Timing bars
    for (var i = 8; i < _n - 8; i++) {
      if (i.isEven) {
        _module(canvas, dark, 6, i, cell);
        _module(canvas, dark, i, 6, cell);
      }
    }
  }

  bool _inFinder(int r, int c) =>
      (r < 8 && c < 8) ||
      (r < 8 && c >= _n - 8) ||
      (r >= _n - 8 && c < 8);

  bool _isTiming(int r, int c) => r == 6 || c == 6;

  void _module(Canvas canvas, Paint p, int r, int c, double cell) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c * cell + 0.6, r * cell + 0.6, cell - 1.2, cell - 1.2),
        const Radius.circular(1.5),
      ),
      p,
    );
  }

  void _finder(Canvas canvas, int r, int c, double cell) {
    final black = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(c * cell, r * cell, 7 * cell, 7 * cell), black);
    canvas.drawRect(
        Rect.fromLTWH((c + 1) * cell, (r + 1) * cell, 5 * cell, 5 * cell),
        white);
    canvas.drawRect(
        Rect.fromLTWH((c + 2) * cell, (r + 2) * cell, 3 * cell, 3 * cell),
        black);
  }

  @override
  bool shouldRepaint(_MockQrPainter old) => old.seed != seed;
}
