import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum PartnerScope { local, global }

class Partner {
  const Partner({
    required this.name,
    required this.category,
    required this.scope,
    required this.tagline,
    this.logoAsset,
    this.brandColor = AppColors.navy,
  });

  final String name;
  final String category;
  final PartnerScope scope;
  final String tagline;

  /// SVG logo path; when null a colored monogram tile is shown instead.
  final String? logoAsset;
  final Color brandColor;

  /// Up-to-two-letter monogram used when no logo asset is available.
  String get monogram {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

// Logo assets shipped with the app are wired up; the rest fall back to a
// branded monogram tile until the real marks are supplied.
const mockPartners = <Partner>[
  // ── Banking & finance (local) ──
  Partner(
    name: 'ABA Bank',
    category: 'Banking & Finance',
    scope: PartnerScope.local,
    tagline: 'Mortgage & investor financing',
    logoAsset: 'assets/icons/base/aba.svg',
  ),
  Partner(
    name: 'ACLEDA Bank',
    category: 'Banking & Finance',
    scope: PartnerScope.local,
    tagline: 'Home loans nationwide',
    logoAsset: 'assets/icons/base/acleda.svg',
  ),
  Partner(
    name: 'Wing Bank',
    category: 'Banking & Finance',
    scope: PartnerScope.local,
    tagline: 'Digital payments & deposits',
    logoAsset: 'assets/icons/base/wing.svg',
  ),

  // ── Developers (local) ──
  Partner(
    name: 'Borey Peng Huoth',
    category: 'Developers',
    scope: PartnerScope.local,
    tagline: 'Master-planned Borey communities',
    brandColor: Color(0xFF0F6B3A),
  ),
  Partner(
    name: 'Vimean Phnom Penh',
    category: 'Developers',
    scope: PartnerScope.local,
    tagline: 'Residential & land projects',
    brandColor: Color(0xFFB8860B),
  ),
  Partner(
    name: 'Chip Mong Land',
    category: 'Developers',
    scope: PartnerScope.local,
    tagline: 'Mixed-use developments',
    brandColor: Color(0xFFC0392B),
  ),
  Partner(
    name: 'Urbanland',
    category: 'Developers',
    scope: PartnerScope.local,
    tagline: 'Smart city living, Chroy Changvar',
    brandColor: Color(0xFF1F6FB2),
  ),

  // ── Legal & valuation (local) ──
  Partner(
    name: 'CVEA',
    category: 'Legal & Valuation',
    scope: PartnerScope.local,
    tagline: 'Cambodian Valuers & Agents Assoc.',
    brandColor: Color(0xFF2C3E50),
  ),
  Partner(
    name: 'Sithi Law',
    category: 'Legal & Valuation',
    scope: PartnerScope.local,
    tagline: 'Title & conveyancing experts',
    brandColor: Color(0xFF34495E),
  ),

  // ── Global partners ──
  Partner(
    name: 'CBRE',
    category: 'Global Advisory',
    scope: PartnerScope.global,
    tagline: 'Global real estate advisory',
    brandColor: Color(0xFF006A4D),
  ),
  Partner(
    name: 'JLL',
    category: 'Global Advisory',
    scope: PartnerScope.global,
    tagline: 'Investment & capital markets',
    brandColor: Color(0xFFE1251B),
  ),
  Partner(
    name: 'Knight Frank',
    category: 'Global Advisory',
    scope: PartnerScope.global,
    tagline: 'International residential network',
    brandColor: Color(0xFF231F20),
  ),
  Partner(
    name: 'Mastercard',
    category: 'Payments',
    scope: PartnerScope.global,
    tagline: 'Secure cross-border payments',
    brandColor: Color(0xFFEB6B1F),
  ),
];

List<Partner> partnersByScope(PartnerScope scope) =>
    mockPartners.where((p) => p.scope == scope).toList();
