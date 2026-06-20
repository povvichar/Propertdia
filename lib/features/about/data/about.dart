import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

/// Static company info for the About screen. Front-end-only mock data — no store
/// is needed because nothing here mutates at runtime.

class TeamMember {
  const TeamMember({
    required this.name,
    required this.position,
    required this.photoUrl,
    this.bio,
    this.location,
    this.yearsExperience,
    this.specialties = const [],
    this.email,
    this.phone,
    this.linkedIn,
  });

  final String name;
  final String position;

  /// Portrait source — either a bundled `assets/...` path or a network URL.
  final String photoUrl;

  /// Resolves [photoUrl] to the right [ImageProvider] (asset vs network).
  ImageProvider get image => photoUrl.startsWith('assets/')
      ? AssetImage(photoUrl) as ImageProvider
      : NetworkImage(photoUrl);

  // ── Optional profile details (shown on the team profile screen) ──
  final String? bio;
  final String? location;
  final int? yearsExperience;
  final List<String> specialties;
  final String? email;
  final String? phone;
  final String? linkedIn;
}

const aboutTeam = <TeamMember>[
  // Only one member carries full profile-detail mock data.
  TeamMember(
    name: 'Va Vanna',
    position: 'Co-Founder & Managing Director',
    photoUrl: 'assets/images/team/va_vanna.png',
    bio:
        'Vanna co-founded PROPERTDIA to bring transparency to Cambodia’s property '
        'market. With over a decade across real estate, fintech, and proptech, he '
        'leads the company’s vision of making every property decision data-driven '
        'and accessible to everyone.',
    location: 'Phnom Penh, Cambodia',
    yearsExperience: 12,
    specialties: ['Proptech Strategy', 'Real Estate', 'Fintech'],
    email: 'vanna@propertdia.com',
    phone: '+855 23 999 001',
    linkedIn: '/in/vavanna',
  ),
  TeamMember(
    name: 'Lanh Them',
    position: 'Property Consultant',
    photoUrl: 'assets/images/team/lanh_them.png',
  ),
  TeamMember(
    name: 'Lim Sophea',
    position: 'Head of Valuation',
    photoUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80',
  ),
  TeamMember(
    name: 'Vong Rithy',
    position: 'Head of Partnerships',
    photoUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
  ),
];

// ── Company details ───────────────────────────────────────────────────────────

const aboutWhoWeAre =
    'PROPERTDIA is a Cambodian property-tech platform built to bring clarity and '
    'trust to real estate. We combine local market knowledge with modern tools so '
    'buyers, sellers, and investors can make confident decisions.';

const aboutMission =
    'Our mission is to make every property decision in Cambodia smarter, faster, and '
    'more transparent — from price discovery and valuation to title verification and '
    'investment.';

const aboutOfficeAddress =
    'No. 168, Preah Norodom Blvd, Sangkat Tonle Bassac, Khan Chamkarmon, Phnom Penh';

const aboutOfficeLocation = LatLng(11.5564, 104.9282);

// Contact handles (shared with Telegram Support screen).
const aboutTelegram = '@propertdia';
const aboutPhone = '+855 23 999 000';
const aboutEmail = 'support@propertdia.com';

// Social handles.
const aboutFacebook = '/propertdia';
const aboutLinkedIn = '/company/propertdia';
