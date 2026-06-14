import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum PostCategory { news, article }

extension PostCategoryX on PostCategory {
  String get label => switch (this) {
        PostCategory.news => 'News',
        PostCategory.article => 'Guide',
      };

  Color get color => switch (this) {
        PostCategory.news => AppColors.info,
        PostCategory.article => AppColors.success,
      };
}

class Post {
  const Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.body,
    required this.imageUrl,
    required this.category,
    required this.source,
    required this.date,
    required this.readMins,
  });

  final String id;
  final String title;
  final String excerpt;
  final List<String> body;
  final String imageUrl;
  final PostCategory category;
  final String source;
  final String date;
  final int readMins;
}

const mockPosts = <Post>[
  Post(
    id: 'm1',
    title: 'Phnom Penh land prices climb 8% in the first half of 2026',
    excerpt:
        'Riverside and satellite-city districts lead the gains as infrastructure projects mature.',
    category: PostCategory.news,
    source: 'Realestate.com.kh',
    date: '13 Jun 2026',
    readMins: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=900&q=80',
    body: [
      'Land values across Phnom Penh rose an average of 8% in the first half of 2026, driven by sustained demand in Chroy Changvar, Sen Sok and the emerging satellite cities along National Road 2.',
      'Analysts point to the new Techo International Airport and improved ring-road access as the main catalysts, with investors repositioning toward titled land plots ahead of expected price appreciation.',
      'Borey developments continue to absorb the bulk of mid-market demand, while riverfront condominiums remain popular with overseas buyers seeking rental yield.',
    ],
  ),
  Post(
    id: 'm2',
    title: 'Hard title vs soft title: what every buyer should know',
    excerpt:
        'Understanding Cambodia’s two ownership systems protects you from costly disputes.',
    category: PostCategory.article,
    source: 'PROPERTDIA Academy',
    date: '11 Jun 2026',
    readMins: 6,
    imageUrl:
        'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=900&q=80',
    body: [
      'In Cambodia, property can be held under a “hard title” (registered at the national cadastral level) or a “soft title” (recognised only by the local commune).',
      'Hard titles offer the strongest legal protection and are required for bank financing and most foreign-linked structures. Soft titles are cheaper and faster to transfer but carry higher dispute risk.',
      'Before buying, always verify the title type, cross-check the cadastral records, and engage a licensed valuer. PROPERTDIA’s Title Services can run these checks on your behalf.',
    ],
  ),
  Post(
    id: 'm3',
    title: 'Techo Airport opening reshapes Kandal land demand',
    excerpt:
        'Plots along the access corridor are attracting both developers and fractional investors.',
    category: PostCategory.news,
    source: 'Khmer Times',
    date: '09 Jun 2026',
    readMins: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=80',
    body: [
      'With the new airport now operational, demand for land in Kandal Stueng and surrounding communes has surged, particularly for plots suited to logistics, hospitality and residential subdivision.',
      'Developers are racing to secure titled land, while smaller investors are increasingly entering through fractional land-split projects that lower the capital barrier to entry.',
    ],
  ),
  Post(
    id: 'm4',
    title: 'How fractional property investment actually works',
    excerpt:
        'Co-invest in vetted Borey and land projects from as little as a few thousand dollars.',
    category: PostCategory.article,
    source: 'PROPERTDIA Academy',
    date: '06 Jun 2026',
    readMins: 5,
    imageUrl:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=900&q=80',
    body: [
      'Fractional investment lets several investors pool capital into a single development, sharing both the returns and the risk in proportion to their contribution.',
      'Each project on PROPERTDIA is pre-vetted by legal and valuation experts, with a target ROI and term published upfront. Returns are distributed as the project hits its milestones.',
      'Because entry tickets start in the low thousands, fractional investing opens up projects that would otherwise require large lump-sum purchases.',
    ],
  ),
  Post(
    id: 'm5',
    title: 'Five things to check before buying a Borey home',
    excerpt:
        'A quick due-diligence checklist for first-time Borey buyers in Cambodia.',
    category: PostCategory.article,
    source: 'PROPERTDIA Academy',
    date: '02 Jun 2026',
    readMins: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=900&q=80',
    body: [
      'Borey communities are popular for their security and amenities, but quality varies widely between developers.',
      'Check the developer’s track record, confirm the title type, review the management fees, inspect the build quality, and confirm what infrastructure (drainage, power, roads) is actually completed versus promised.',
    ],
  ),
];
