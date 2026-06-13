class Property {
  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.beds,
    required this.baths,
    required this.areaSqm,
    this.tag = 'For Sale',
    this.propertyType = 'Villa',
    this.fullAddress,
    this.description,
    this.agentName = 'Chan Rithy',
    this.agentRole = 'Property Consultant',
    this.agentAvatar,
    this.features = const <String>[],
    this.gallery = const <String>[],
    this.lat,
    this.lng,
  });

  final String id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final int beds;
  final int baths;
  final int areaSqm;
  final String tag;
  final String propertyType;
  final String? fullAddress;
  final String? description;
  final String agentName;
  final String agentRole;
  final String? agentAvatar;
  final List<String> features;
  final List<String> gallery;

  /// Map coordinates (only populated for map listings).
  final double? lat;
  final double? lng;

  bool get isRent => tag.toLowerCase().contains('rent');

  /// Compact price for a map pin, e.g. `$485K` or `$1.3K/mo`.
  String get pinPrice {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return price;
    final n = int.parse(digits);
    String s;
    if (n >= 1000000) {
      s = '\$${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      final k = n / 1000;
      s = '\$${k >= 100 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
    } else {
      s = '\$$n';
    }
    return isRent ? '$s/mo' : s;
  }
}

const mockBestPrice = [
  Property(
    id: 'p1',
    title: 'Modern Pool Villa',
    location: 'Chamkarmon, Phnom Penh',
    price: '\$485,000',
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
    beds: 4,
    baths: 5,
    areaSqm: 420,
    propertyType: 'Pool Villa',
    fullAddress: 'No. 45, Street 310, Chamkarmon, Phnom Penh',
    description:
        'This stunning modern villa features an open-concept design with floor-to-ceiling windows, a private infinity pool, and lush tropical landscaping. Located in the heart of Chamkarmon, offering easy access to international schools, restaurants, and business districts.',
    agentName: 'Chan Rithy',
    agentRole: 'Property Consultant',
    agentAvatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    features: <String>[
      'Private infinity pool with sun deck',
      'Open-concept kitchen with premium appliances',
      'Home theatre & media room',
      'Smart home automation system',
      '4-car underground garage',
      '24/7 security & CCTV',
    ],
    gallery: <String>[
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
      'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800&q=80',
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
      'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800&q=80',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80',
    ],
  ),
  Property(
    id: 'p2',
    title: 'Riverside Sky Condo',
    location: 'Daun Penh, Phnom Penh',
    price: '\$168,000',
    imageUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=900&q=80',
    beds: 2,
    baths: 2,
    areaSqm: 96,
    propertyType: 'Condo',
    fullAddress: 'Unit 18F, The Peak Tower, Sisowath Quay, Daun Penh',
    description:
        'A sleek high-rise condo with panoramic Mekong River views. The unit features a fully fitted kitchen, balcony, and access to rooftop amenities including a pool and gym. Ideal for professionals and investors.',
    agentName: 'Sophea Lim',
    agentRole: 'Senior Sales Agent',
    agentAvatar:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    features: <String>[
      'Panoramic Mekong River views',
      'Fully fitted European kitchen',
      'Rooftop infinity pool & gym',
      'Covered parking slot included',
      '24/7 concierge & security',
    ],
    gallery: <String>[
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=900&q=80',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=80',
      'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=800&q=80',
    ],
  ),
  Property(
    id: 'p3',
    title: 'Borey Twin Villa',
    location: 'Sen Sok, Phnom Penh',
    price: '\$262,000',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
    beds: 5,
    baths: 6,
    areaSqm: 360,
    propertyType: 'Twin Villa',
    fullAddress: 'Borey Peng Huoth, Street 2011, Sen Sok, Phnom Penh',
    description:
        'Spacious twin villa inside a gated borey community. Features five bedrooms, private garden, and a double garage. Close to AEON Mall, international schools, and major expressways.',
    agentName: 'Dara Kim',
    agentRole: 'Property Advisor',
    agentAvatar:
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&q=80',
    features: <String>[
      'Private garden & double garage',
      'Gated community with security',
      'Spacious open-plan living area',
      'Built-in wardrobes in all bedrooms',
      'Close to AEON Mall & expressways',
    ],
    gallery: <String>[
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
      'https://images.unsplash.com/photo-1586105251261-72a756497a11?w=800&q=80',
      'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=80',
      'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800&q=80',
    ],
  ),
];

const mockRecommended = [
  Property(
    id: 'p4',
    title: 'Garden Link House',
    location: 'Chroy Changvar, Phnom Penh',
    price: '\$138,000',
    imageUrl:
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=900&q=80',
    beds: 3,
    baths: 3,
    areaSqm: 180,
    propertyType: 'Link House',
  ),
  Property(
    id: 'p5',
    title: 'BKK1 Serviced Apartment',
    location: 'BKK1, Phnom Penh',
    price: '\$1,250/mo',
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=900&q=80',
    beds: 2,
    baths: 2,
    areaSqm: 110,
    tag: 'For Rent',
    propertyType: 'Apartment',
  ),
  Property(
    id: 'p6',
    title: 'Commercial Land Plot',
    location: 'National Road 6, Siem Reap',
    price: '\$95/sqm',
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80',
    beds: 0,
    baths: 0,
    areaSqm: 1200,
    propertyType: 'Land',
  ),
];

/// Phnom Penh listings positioned on the Map Price interactive map.
const mockMapProperties = <Property>[
  Property(
    id: 'm1',
    title: 'BKK1 Designer Condo',
    location: 'BKK1, Chamkarmon',
    price: '\$189,000',
    imageUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
    beds: 2,
    baths: 2,
    areaSqm: 92,
    tag: 'For Sale',
    propertyType: 'Condo',
    agentName: 'Sophea Lim',
    agentRole: 'Senior Sales Agent',
    agentAvatar:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    lat: 11.5486,
    lng: 104.9225,
  ),
  Property(
    id: 'm2',
    title: 'Riverside Serviced Flat',
    location: 'Sisowath Quay, Daun Penh',
    price: '\$1,250/mo',
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
    beds: 1,
    baths: 1,
    areaSqm: 64,
    tag: 'For Rent',
    propertyType: 'Apartment',
    agentName: 'Dara Kim',
    agentRole: 'Leasing Advisor',
    agentAvatar:
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&q=80',
    lat: 11.5715,
    lng: 104.9305,
  ),
  Property(
    id: 'm3',
    title: 'Tuol Kork Modern Villa',
    location: 'Tuol Kork, Phnom Penh',
    price: '\$520,000',
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
    beds: 4,
    baths: 5,
    areaSqm: 320,
    tag: 'For Sale',
    propertyType: 'Villa',
    agentName: 'Chan Rithy',
    agentRole: 'Property Consultant',
    agentAvatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    lat: 11.5792,
    lng: 104.8948,
  ),
  Property(
    id: 'm4',
    title: 'Chamkarmon Shophouse',
    location: 'Street 360, Chamkarmon',
    price: '\$295,000',
    imageUrl:
        'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800&q=80',
    beds: 3,
    baths: 4,
    areaSqm: 168,
    tag: 'For Sale',
    propertyType: 'Shophouse',
    agentName: 'Nida Sok',
    agentRole: 'Property Advisor',
    agentAvatar:
        'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=200&q=80',
    lat: 11.5402,
    lng: 104.9175,
  ),
  Property(
    id: 'm5',
    title: 'Daun Penh Sky Penthouse',
    location: 'Wat Phnom, Daun Penh',
    price: '\$2,800/mo',
    imageUrl:
        'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=800&q=80',
    beds: 3,
    baths: 3,
    areaSqm: 145,
    tag: 'For Rent',
    propertyType: 'Penthouse',
    agentName: 'Visal Chea',
    agentRole: 'Luxury Leasing',
    agentAvatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    lat: 11.5768,
    lng: 104.9268,
  ),
  Property(
    id: 'm6',
    title: 'Sen Sok Borey Twin',
    location: 'Borey Peng Huoth, Sen Sok',
    price: '\$262,000',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
    beds: 5,
    baths: 6,
    areaSqm: 360,
    tag: 'For Sale',
    propertyType: 'Twin Villa',
    agentName: 'Dara Kim',
    agentRole: 'Property Advisor',
    agentAvatar:
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&q=80',
    lat: 11.6052,
    lng: 104.8985,
  ),
  Property(
    id: 'm7',
    title: 'Chroy Changvar Condo',
    location: 'Peninsula, Chroy Changvar',
    price: '\$980/mo',
    imageUrl:
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
    beds: 2,
    baths: 2,
    areaSqm: 78,
    tag: 'For Rent',
    propertyType: 'Condo',
    agentName: 'Sophea Lim',
    agentRole: 'Leasing Agent',
    agentAvatar:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    lat: 11.5882,
    lng: 104.9418,
  ),
  Property(
    id: 'm8',
    title: 'Tonle Bassac Apartment',
    location: 'Tonle Bassac, Chamkarmon',
    price: '\$165,000',
    imageUrl:
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=80',
    beds: 2,
    baths: 1,
    areaSqm: 70,
    tag: 'For Sale',
    propertyType: 'Apartment',
    agentName: 'Nida Sok',
    agentRole: 'Property Advisor',
    agentAvatar:
        'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=200&q=80',
    lat: 11.5520,
    lng: 104.9298,
  ),
];
