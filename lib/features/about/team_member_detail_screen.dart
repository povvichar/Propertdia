import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/utils/l10n_ext.dart';
import '../../shared/widgets/bottom_fade_overlay.dart';
import '../../shared/widgets/glass_icon_button.dart';
import 'data/about.dart';

/// Profile detail for a single [TeamMember], opened from a team card on the
/// About screen. Rich fields are optional — the screen null-guards each one so
/// members without full mock data still render cleanly.
class TeamMemberDetailScreen extends StatelessWidget {
  const TeamMemberDetailScreen({super.key, required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final m = member;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Navy header + overlapping avatar ──────────────────────
                SizedBox(
                  height: 196 + topInset,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150 + topInset,
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroHeader,
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(28)),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.surfaceMuted,
                              backgroundImage: m.image,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Name + position ───────────────────────────────────────
                Text(
                  m.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.position,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
                if (m.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/base/mappin.svg',
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        m.location!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── About ──────────────────────────────────────────
                      if (m.bio != null || m.yearsExperience != null) ...[
                        _SectionLabel(context.l10n.teamAboutLabel),
                        _Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.bio != null)
                                  Text(
                                    m.bio!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                if (m.yearsExperience != null) ...[
                                  if (m.bio != null) const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/base/clock.svg',
                                        width: 18,
                                        height: 18,
                                        colorFilter: const ColorFilter.mode(
                                            AppColors.goldDark, BlendMode.srcIn),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n
                                      .teamYearsExperience(m.yearsExperience!),
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
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Specialties ────────────────────────────────────
                      if (m.specialties.isNotEmpty) ...[
                        _SectionLabel(context.l10n.teamSpecialtiesLabel),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in m.specialties) _SpecialtyChip(s),
                          ],
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Contact ────────────────────────────────────────
                      if (m.email != null ||
                          m.phone != null ||
                          m.linkedIn != null) ...[
                        _SectionLabel(context.l10n.teamContactLabel),
                        _Card(
                          child: Column(
                            children: [
                              if (m.email != null)
                                _LinkRow(
                                  icon: 'assets/icons/base/email.svg',
                                  label: context.l10n.teamEmail,
                                  subtitle: m.email!,
                                  onTap: () {},
                                ),
                              if (m.email != null && m.phone != null)
                                const _RowDivider(),
                              if (m.phone != null)
                                _LinkRow(
                                  icon: 'assets/icons/base/phone.svg',
                                  label: context.l10n.teamPhone,
                                  subtitle: m.phone!,
                                  onTap: () {},
                                ),
                              if (m.phone != null && m.linkedIn != null)
                                const _RowDivider(),
                              if (m.linkedIn != null)
                                _LinkRow(
                                  icon: 'assets/icons/base/linkedin.svg',
                                  label: 'LinkedIn',
                                  subtitle: m.linkedIn!,
                                  onTap: () {},
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // ── Glass back button ─────────────────────────────────────────
            Positioned(
              top: topInset + 8,
              left: 16,
              child: GlassIconButton(
                asset: 'assets/icons/base/careleft.svg',
                onTap: () => Navigator.of(context).pop(),
                iconColor: Colors.white,
                fillColor: Colors.white.withValues(alpha: 0.18),
                borderColor: Colors.white.withValues(alpha: 0.30),
              ),
            ),

            // ── Bottom glass fade as content exits the viewport ───────────
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomFadeOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets (mirrors the About screen styling) ───────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 50),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.navyIcon,
        ),
      ),
    );
  }
}

class _LinkRow extends StatefulWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });
  final String icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? AppColors.surfaceMuted : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              widget.icon,
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/base/careright.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
