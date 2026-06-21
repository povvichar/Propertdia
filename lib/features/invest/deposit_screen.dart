import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/invest.dart';

enum _Step { amount, pay, done }

/// Full-screen deposit flow — a payment in progress can't be swiped away by
/// accident, and every step carries the transaction record.
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountCtrl = TextEditingController();
  String _method = payMethods.first.name;
  _Step _step = _Step.amount;

  late String _ref;
  late DateTime _created;
  static const _ttl = 900; // 15 min QR validity
  int _left = _ttl;
  Timer? _timer;

  int get _amount =>
      int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  bool get _amountValid => _amount >= 10;
  bool get _expired => _left <= 0;

  @override
  void dispose() {
    _timer?.cancel();
    _amountCtrl.dispose();
    super.dispose();
  }

  String _newRef() {
    final d = _created;
    final ymd =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final rand = (1000 + Random().nextInt(8999)).toString();
    return 'TXN-$ymd-$rand';
  }

  void _startTimer() {
    _timer?.cancel();
    _left = _ttl;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 0) {
        t.cancel();
        setState(() {});
      } else {
        setState(() => _left--);
      }
    });
  }

  void _toPay() {
    setState(() {
      _created = DateTime.now();
      _ref = _newRef();
      _step = _Step.pay;
    });
    _startTimer();
  }

  void _refreshQr() {
    setState(() {
      _created = DateTime.now();
      _ref = _newRef();
    });
    _startTimer();
  }

  void _confirmPaid() {
    _timer?.cancel();
    investStore.submitDeposit(_amount, _method);
    setState(() => _step = _Step.done);
  }

  void _back() {
    if (_step == _Step.pay) {
      _timer?.cancel();
      setState(() => _step = _Step.amount);
    } else {
      context.pop();
    }
  }

  String get _clock {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _title => switch (_step) {
        _Step.amount => 'Deposit funds',
        _Step.pay => 'Scan to pay',
        _Step.done => 'Payment submitted',
      };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    GlassIconButton(
                      asset: 'assets/icons/base/careleft.svg',
                      onTap: _back,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (_step) {
                  _Step.amount => _amountStep(),
                  _Step.pay => _payStep(),
                  _Step.done => _doneStep(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1 · amount ──────────────────────────────────────────────────────
  Widget _amountStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              Text(
                'How much would you like to add?',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 24),
              // ── Open amount entry (fintech style — no box) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: _amount > 0
                          ? AppColors.navy
                          : AppColors.textSecondary.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsFormatter(),
                      ],
                      onChanged: (_) => setState(() {}),
                      cursorColor: AppColors.gold,
                      cursorWidth: 2.5,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        border: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.divider, width: 1.5),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.divider, width: 1.5),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.gold, width: 2),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.2),
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'USD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Min. \$10 · Max. \$1,000',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final q in const [100, 500, 1000, 5000])
                    GestureDetector(
                      onTap: () => setState(() {
                        _amountCtrl.text = _ThousandsFormatter.format(q);
                        _amountCtrl.selection = TextSelection.collapsed(
                            offset: _amountCtrl.text.length);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: _amount == q
                              ? AppColors.navy
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usd(q),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _amount == q ? Colors.white : AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Pay via',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final m in payMethods) ...[
                    Expanded(
                      child: _MethodChip(
                        method: m,
                        selected: _method == m.name,
                        onTap: () => setState(() => _method = m.name),
                      ),
                    ),
                    if (m != payMethods.last) const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
        _BottomBar(
          child: PrimaryButton(
            label: 'Continue to Payment',
            trailingIcon: 'assets/icons/base/arrowright.svg',
            enabled: _amountValid,
            onPressed: () {
              if (_amountValid) _toPay();
            },
          ),
        ),
      ],
    );
  }

  // ── Step 2 · KHQR payment ────────────────────────────────────────────────
  Widget _payStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              _TxnInfoCard(
                rows: [
                  ('Reference', _ref),
                  ('Amount', '${usd(_amount)} USD'),
                  ('Pay via', _method),
                  ('Requested', fmtDateTime(_created)),
                ],
                status: _expired ? 'Expired' : 'Awaiting payment',
                statusColor: _expired ? AppColors.danger : AppColors.gold,
              ),
              const SizedBox(height: 16),
              _KhqrCard(
                amount: _amount,
                method: _method,
                expired: _expired,
                clock: _clock,
                onRefresh: _refreshQr,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/base/shield.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                        AppColors.textSecondary.withValues(alpha: 0.8),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep this screen open until your payment is confirmed. '
                      'Funds are credited after our team verifies the transfer.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _BottomBar(
          child: PrimaryButton(
            label: _expired ? 'QR expired — refresh' : "I've Paid",
            trailingIcon: null,
            enabled: !_expired,
            onPressed: () {
              if (_expired) {
                _refreshQr();
              } else {
                _confirmPaid();
              }
            },
          ),
        ),
      ],
    );
  }

  // ── Step 3 · submitted ───────────────────────────────────────────────────
  Widget _doneStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            children: [
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.goldSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/base/clock.svg',
                      width: 34,
                      height: 34,
                      colorFilter: const ColorFilter.mode(
                          AppColors.goldDark, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Payment submitted',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Your deposit is awaiting confirmation. Your balance '
                  'updates as soon as it is approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _TxnInfoCard(
                rows: [
                  ('Reference', _ref),
                  ('Amount', '${usd(_amount)} USD'),
                  ('Pay via', _method),
                  ('Submitted', fmtDateTime(_created)),
                ],
                status: 'Under review',
                statusColor: AppColors.gold,
              ),
            ],
          ),
        ),
        _BottomBar(
          child: PrimaryButton(
            label: 'Done',
            trailingIcon: null,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

// ── Transaction info card ────────────────────────────────────────────────────

class _TxnInfoCard extends StatelessWidget {
  const _TxnInfoCard({
    required this.rows,
    required this.status,
    required this.statusColor,
  });

  final List<(String, String)> rows;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Transaction',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor == AppColors.gold
                        ? AppColors.goldDark
                        : statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final r in rows) ...[
            const Divider(height: 18, color: AppColors.border),
            Row(
              children: [
                Text(
                  r.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  r.$2,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── KHQR card ────────────────────────────────────────────────────────────────

class _KhqrCard extends StatelessWidget {
  const _KhqrCard({
    required this.amount,
    required this.method,
    required this.expired,
    required this.clock,
    required this.onRefresh,
  });

  final int amount;
  final String method;
  final bool expired;
  final String clock;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE21B22),
            child: Row(
              children: [
                const Text(
                  'KHQR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'via $method',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              children: [
                const Text(
                  'PROPERTDIA Pte Ltd',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${usd(amount)} USD',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 188,
                      height: 188,
                      child: CustomPaint(painter: _QrPainter(amount + 7)),
                    ),
                    if (expired)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: onRefresh,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/base/refresh.svg',
                                    width: 26,
                                    height: 26,
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.navy, BlendMode.srcIn),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Refresh QR',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (!expired)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/base/clock.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Expires in $clock',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  'Scan with ABA, ACLEDA, Wing or any Bakong app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final m in payMethods) ...[
                      SizedBox(
                        height: 18,
                        child: SvgPicture.asset(m.logo, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, 14, 20, bottomInset > 0 ? bottomInset : 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.7), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 22,
              child: SvgPicture.asset(method.logo, fit: BoxFit.contain),
            ),
            const SizedBox(height: 4),
            Text(
              method.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Thousands formatter ───────────────────────────────────────────────────────

class _ThousandsFormatter extends TextInputFormatter {
  static const _maxDigits = 9;

  static String format(int n) => _addCommas(n.toString());

  static String _addCommas(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    if (digits.length > _maxDigits) return oldValue;
    final formatted = _addCommas(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Decorative QR matrix (with three finder squares) ─────────────────────────

class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);

  final int seed;
  static const _n = 25;

  bool _finderDark(int lx, int ly) =>
      lx == 0 ||
      lx == 6 ||
      ly == 0 ||
      ly == 6 ||
      (lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final paint = Paint()..color = const Color(0xFF101828);

    final finders = [
      const [0, 0],
      [_n - 7, 0],
      [0, _n - 7],
    ];

    bool inFinderZone(int x, int y) {
      for (final f in finders) {
        if (x >= f[0] - 1 && x <= f[0] + 7 && y >= f[1] - 1 && y <= f[1] + 7) {
          return true;
        }
      }
      return false;
    }

    var s = seed * 2654435761 & 0x7fffffff;
    int next() {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      return s;
    }

    void square(int x, int y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          Radius.circular(cell * 0.2),
        ),
        paint,
      );
    }

    for (final f in finders) {
      for (var ly = 0; ly < 7; ly++) {
        for (var lx = 0; lx < 7; lx++) {
          if (_finderDark(lx, ly)) square(f[0] + lx, f[1] + ly);
        }
      }
    }

    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if (inFinderZone(x, y)) continue;
        if (next() % 100 < 46) square(x, y);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.seed != seed;
}
