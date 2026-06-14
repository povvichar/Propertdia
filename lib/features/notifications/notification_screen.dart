import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum _NType { listing, priceDrop, application, investment, system }

class _Notif {
  const _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.imageUrl,
  });

  final String id;
  final _NType type;
  final String title;
  final String body;
  final String time;
  final bool read;
  final String? imageUrl;
}

const _mockNotifs = [
  // Today
  _Notif(
    id: 'n1',
    type: _NType.priceDrop,
    title: 'Price Drop Alert',
    body: 'BKK1 Designer Condo dropped \$9,000 — now \$180,000.',
    time: '10 min ago',
    imageUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=200&q=60',
  ),
  _Notif(
    id: 'n2',
    type: _NType.listing,
    title: 'New Match in Sen Sok',
    body: 'A new villa matching your saved search just listed for \$262,000.',
    time: '1 hr ago',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=200&q=60',
  ),
  _Notif(
    id: 'n3',
    type: _NType.application,
    title: 'Title Application Updated',
    body:
        'Your title verification for Street 310 property is under review by MLMUPC.',
    time: '3 hr ago',
    read: true,
  ),
  // Yesterday
  _Notif(
    id: 'n4',
    type: _NType.investment,
    title: 'Investment Dividend Paid',
    body: 'You received \$18.50 monthly return from Gold Tower Project.',
    time: 'Yesterday, 4:32 PM',
    read: true,
  ),
  _Notif(
    id: 'n5',
    type: _NType.priceDrop,
    title: 'Price Drop Alert',
    body: 'Daun Penh Sky Penthouse reduced to \$2,600/mo from \$2,800/mo.',
    time: 'Yesterday, 11:15 AM',
    read: true,
    imageUrl:
        'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=200&q=60',
  ),
  _Notif(
    id: 'n6',
    type: _NType.listing,
    title: 'Force Sale — New Listing',
    body:
        'A 3-bedroom shophouse in Chamkarmon just entered force sale at \$195,000.',
    time: 'Yesterday, 9:02 AM',
    read: true,
  ),
  // Earlier
  _Notif(
    id: 'n7',
    type: _NType.application,
    title: 'KYC Verification Approved',
    body:
        'Your identity has been verified. You can now access all platform features.',
    time: 'Mon, 9 Jun',
    read: true,
  ),
  _Notif(
    id: 'n8',
    type: _NType.system,
    title: 'Welcome to Propertdia',
    body:
        'Explore Map Price, Estimate, and Title Services to get the most out of your account.',
    time: 'Sun, 8 Jun',
    read: true,
  ),
];

const _sections = [
  ('Today', [0, 1, 2]),
  ('Yesterday', [3, 4, 5]),
  ('Earlier', [6, 7]),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final List<_Notif> _notifs = List.of(_mockNotifs);

  int get _unreadCount => _notifs.where((n) => !n.read).length;

  void _markAllRead() =>
      setState(() => _notifs.replaceRange(0, _notifs.length,
          _notifs.map((n) => _Notif(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                time: n.time,
                read: true,
                imageUrl: n.imageUrl,
              ))));

  void _markRead(String id) => setState(() {
        final i = _notifs.indexWhere((n) => n.id == id);
        if (i != -1) {
          final n = _notifs[i];
          _notifs[i] = _Notif(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            time: n.time,
            read: true,
            imageUrl: n.imageUrl,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 48,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          actions: [
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _markAllRead,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            for (final (label, indices) in _sections) ...[
              _SectionHeader(label: label),
              for (final i in indices)
                _NotifTile(
                  notif: _notifs[i],
                  onTap: () => _markRead(_notifs[i].id),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});

  final _Notif notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notif.read ? Colors.transparent : AppColors.gold.withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon or property thumbnail.
            notif.imageUrl != null
                ? _Thumbnail(url: notif.imageUrl!, type: notif.type)
                : _TypeIcon(type: notif.type),
            const SizedBox(width: 12),

            // Content.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + unread dot.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.read
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (!notif.read) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Body.
                  Text(
                    notif.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Timestamp.
                  Text(
                    notif.time,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Property thumbnail ────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.type});

  final String url;
  final _NType type;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, p) =>
                p == null ? child : Container(color: AppColors.iconTile, width: 52, height: 52),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: _TypeBadge(type: type, size: 20),
        ),
      ],
    );
  }
}

// ── Type icon (no thumbnail) ──────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});
  final _NType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _typeColor(type).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: SvgPicture.asset(
          _typeAsset(type),
          width: 24,
          height: 24,
          colorFilter:
              ColorFilter.mode(_typeColor(type), BlendMode.srcIn),
        ),
      ),
    );
  }
}

// ── Small badge overlaid on thumbnail ────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.size});
  final _NType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _typeColor(type),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: SvgPicture.asset(
          _typeAsset(type),
          width: size * 0.52,
          height: size * 0.52,
          colorFilter:
              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _typeColor(_NType t) => switch (t) {
      _NType.listing => AppColors.navy,
      _NType.priceDrop => AppColors.success,
      _NType.application => AppColors.gold,
      _NType.investment => AppColors.info,
      _NType.system => AppColors.textSecondary,
    };

String _typeAsset(_NType t) => switch (t) {
      _NType.listing => 'assets/icons/base/home.svg',
      _NType.priceDrop => 'assets/icons/base/tag_price.svg',
      _NType.application => 'assets/icons/base/history.svg',
      _NType.investment => 'assets/icons/base/earning.svg',
      _NType.system => 'assets/icons/base/bell.svg',
    };
