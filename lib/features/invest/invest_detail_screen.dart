import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/invest.dart';
import 'widgets/invest_sheets.dart';
import 'widgets/invest_widgets.dart';

class InvestDetailScreen extends StatelessWidget {
  const InvestDetailScreen({super.key, required this.project});

  final InvestProject project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final gallery = [p.imageUrl, ...kGalleryExtras];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero image
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 11,
                      child: Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.surfaceMuted),
                      ),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x33000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Chip(label: p.type.label, color: p.type.color),
                            const SizedBox(width: 8),
                            _Chip(
                              label:
                                  '${p.targetRoi.toStringAsFixed(0)}% target ROI',
                              color: AppColors.gold,
                              dark: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/base/mappin.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Funding progress
                        _FundingCard(project: p),
                        const SizedBox(height: 14),

                        // Key facts
                        _FactGrid(project: p),
                        const SizedBox(height: 14),

                        // Trust strip — full breakdown opens in a sheet
                        const _ProtectionBanner(),
                        const SizedBox(height: 22),

                        const _Heading('Gallery'),
                        const SizedBox(height: 12),
                        _PhotoGallery(images: gallery),
                        const SizedBox(height: 22),

                        const _Heading('About this project'),
                        const SizedBox(height: 8),
                        Text(
                          p.summary,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.55,
                          ),
                        ),
                        if (p.dividends.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const _Heading('Dividend distribution'),
                          const SizedBox(height: 12),
                          for (final d in p.dividends) _DividendRow(record: d),
                        ],

                        const SizedBox(height: 22),
                        const _Heading('Documents'),
                        const SizedBox(height: 4),
                        const Text(
                          'Verified due-diligence files for this project.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final d in kProjectDocs) _DocRow(doc: d),

                        const SizedBox(height: 22),
                        const _ContactCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top bar (floating over hero)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GlassIconButton(
                      asset: 'assets/icons/base/careleft.svg',
                      onTap: () => context.pop(),
                    ),
                    const Spacer(),
                    FavoriteButton(project: p, onDark: true, size: 40),
                  ],
                ),
              ),
            ),

            // Bottom invest CTA — frosted glass bar over scrolling content
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: AnimatedBuilder(
                        animation: investStore,
                        builder: (context, _) {
                          final invested = investStore.investedIn(p.id);
                          final has = invested > 0;
                          return Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    has ? 'You invested' : 'Min. investment',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    usd(has ? invested : p.minInvest),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: has
                                          ? AppColors.success
                                          : AppColors.navy,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: PrimaryButton(
                                  label: has ? 'Invest More' : 'Invest Now',
                                  trailingIcon: null,
                                  onPressed: () => runInvest(context, p),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundingCard extends StatelessWidget {
  const _FundingCard({required this.project});

  final InvestProject project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                usd(p.raised),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'raised of ${usd(p.goal)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(p.fundedPct * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FundingBar(pct: p.fundedPct),
        ],
      ),
    );
  }
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.project});

  final InvestProject project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Fact(
              icon: 'assets/icons/base/earning.svg',
              value: '${p.targetRoi.toStringAsFixed(0)}%',
              label: 'Target ROI',
            ),
          ),
          const _Divider(),
          Expanded(
            child: _Fact(
              icon: 'assets/icons/base/clock.svg',
              value: '${p.termMonths} mo',
              label: 'Term',
            ),
          ),
          const _Divider(),
          Expanded(
            child: _Fact(
              icon: 'assets/icons/base/wallet.svg',
              value: usd(p.minInvest),
              label: 'Min. entry',
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.value, required this.label});

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: AppColors.border);
  }
}

class _DividendRow extends StatelessWidget {
  const _DividendRow({required this.record});

  final DividendRecord record;

  @override
  Widget build(BuildContext context) {
    final reinvested = record.amount == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/earning.svg',
                width: 18,
                height: 18,
                colorFilter:
                    const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.note,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            reinvested ? 'Reinvested' : '+${usd(record.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: reinvested
                  ? AppColors.textSecondary
                  : const Color(0xFF0F8A4F),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact trust strip; tapping (or the ⓘ) opens the full protections sheet.
class _ProtectionBanner extends StatelessWidget {
  const _ProtectionBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProtectionsSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/base/shield.svg',
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(AppColors.success, BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protected investment',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Hard title · escrow · independently vetted',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline_rounded,
                size: 19, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => _GalleryViewer(images: images, initial: i),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  images[i],
                  width: 112,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 112,
                    height: 82,
                    color: AppColors.surfaceMuted,
                  ),
                ),
                if (i == images.length - 1 && images.length > 1)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: AppColors.navy.withValues(alpha: 0.35),
                      child: Text(
                        '${images.length} photos',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen swipeable photo viewer with a counter and close button.
class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({required this.images, required this.initial});

  final List<String> images;
  final int initial;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GlassIconButton(
                    asset: 'assets/icons/base/close.svg',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_index + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc});

  final ProjectDoc doc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDocSheet(context, doc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/file_text.svg',
                  width: 19,
                  height: 19,
                  colorFilter:
                      const ColorFilter.mode(AppColors.danger, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PDF · ${doc.size}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/base/downloadsimple.svg',
              width: 19,
              height: 19,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.navyDepth,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Questions about this project?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Talk to a PROPERTDIA investment advisor before you commit.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: 'assets/icons/base/telegram.svg',
                  label: 'Telegram',
                  filled: true,
                  onTap: () =>
                      investToast(context, 'Opening Telegram · $kAdvisorTelegram'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  icon: 'assets/icons/base/phone.svg',
                  label: 'Call',
                  filled: false,
                  onTap: () => investToast(context, 'Calling $kAdvisorPhone'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? AppColors.gold : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 17,
              height: 17,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.dark = false});

  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: dark ? AppColors.navy : Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
