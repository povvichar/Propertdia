import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/utils/l10n_ext.dart';
import '../../shared/widgets/bottom_fade_overlay.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import 'data/about.dart';

/// Company "About" page, opened from the gold logo in the home header.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                ModuleHeroSliver(
              title: context.l10n.aboutTitle,
              headline: context.l10n.aboutHeadline,
              subtitle: context.l10n.aboutSubtitle,
              icon: 'assets/icons/base/propertdia-white.svg',
              iconSize: 176,
              iconTop: 10,
              iconRight: -20,
            ),
            ModuleHeroSheet(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Who we are ────────────────────────────────────────────
                  _SectionLabel(context.l10n.aboutWhoWeAreLabel),
                  const _Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(aboutWhoWeAre, style: _bodyStyle),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Our mission ───────────────────────────────────────────
                  _SectionLabel(context.l10n.aboutMissionLabel),
                  _Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(aboutMission, style: _bodyStyle),
                          const SizedBox(height: 16),
                          _ValueRow(
                            icon: 'assets/icons/base/target.svg',
                            text: context.l10n.aboutValuePricing,
                          ),
                          const SizedBox(height: 12),
                          _ValueRow(
                            icon: 'assets/icons/base/shield_user.svg',
                            text: context.l10n.aboutValueTitles,
                          ),
                          const SizedBox(height: 12),
                          _ValueRow(
                            icon: 'assets/icons/base/globe.svg',
                            text: context.l10n.aboutValueAccess,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Our team ──────────────────────────────────────────────
                  _SectionLabel(context.l10n.aboutTeamLabel),
                  const _TeamGrid(),
                  const SizedBox(height: 24),

                  // ── Office location ───────────────────────────────────────
                  _SectionLabel(context.l10n.aboutOfficeLabel),
                  const _OfficeCard(),
                  const SizedBox(height: 24),

                  // ── Contact us ────────────────────────────────────────────
                  _SectionLabel(context.l10n.aboutContactLabel),
                  _Card(
                    child: Column(
                      children: [
                        _LinkRow(
                          icon: 'assets/icons/base/telegram.svg',
                          label: context.l10n.aboutChatTelegram,
                          subtitle: aboutTelegram,
                          onTap: () {},
                        ),
                        const _RowDivider(),
                        _LinkRow(
                          icon: 'assets/icons/base/phone.svg',
                          label: context.l10n.aboutCallSupport,
                          subtitle: aboutPhone,
                          onTap: () {},
                        ),
                        const _RowDivider(),
                        _LinkRow(
                          icon: 'assets/icons/base/email.svg',
                          label: context.l10n.aboutEmailUs,
                          subtitle: aboutEmail,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Follow us ─────────────────────────────────────────────
                  _SectionLabel(context.l10n.aboutFollowLabel),
                  _Card(
                    child: Column(
                      children: [
                        _LinkRow(
                          icon: 'assets/icons/base/facebook.svg',
                          label: 'Facebook',
                          subtitle: aboutFacebook,
                          onTap: () {},
                        ),
                        const _RowDivider(),
                        _LinkRow(
                          icon: 'assets/icons/base/linkedin.svg',
                          label: 'LinkedIn',
                          subtitle: aboutLinkedIn,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
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

const _bodyStyle = TextStyle(
  fontSize: 14,
  height: 1.55,
  color: AppColors.textSecondary,
);

// ── Section label ─────────────────────────────────────────────────────────────

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

// ── White rounded card ──────────────────────────────────────────────────────

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

// ── Mission value row ─────────────────────────────────────────────────────────

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter:
                  const ColorFilter.mode(AppColors.goldDark, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Team grid ─────────────────────────────────────────────────────────────────

class _TeamGrid extends StatelessWidget {
  const _TeamGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: [
        for (final m in aboutTeam) _TeamCard(member: m),
      ],
    );
  }
}

class _TeamCard extends StatefulWidget {
  const _TeamCard({required this.member});
  final TeamMember member;

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    return GestureDetector(
      onTap: () => context.push('/about/team', extra: member),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.surfaceMuted,
            backgroundImage: member.image,
          ),
          const SizedBox(height: 12),
          Text(
            member.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            member.position,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              color: AppColors.textSecondary,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Office card (map + address) ─────────────────────────────────────────────

class _OfficeCard extends StatelessWidget {
  const _OfficeCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: aboutOfficeLocation,
                initialZoom: 15,
                minZoom: 11,
                maxZoom: 18,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.propertdia.app',
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: aboutOfficeLocation,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: _OfficePin(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/base/mappin.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                      AppColors.navyIcon, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    aboutOfficeAddress,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _RowDivider(),
          _LinkRow(
            icon: 'assets/icons/base/map_arrow.svg',
            label: context.l10n.aboutGetDirections,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _OfficePin extends StatelessWidget {
  const _OfficePin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppColors.cardShadow,
      ),
    );
  }
}

// ── Link row (icon + label + optional subtitle + chevron) ───────────────────

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
