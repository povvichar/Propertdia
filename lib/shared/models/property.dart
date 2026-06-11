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
}

/// Mock listings for the client-facing UI demo.
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
  ),
];
