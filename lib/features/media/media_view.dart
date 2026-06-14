import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'data/media.dart';

class MediaView extends StatefulWidget {
  const MediaView({super.key});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  PostCategory? _filter;

  List<Post> get _posts => _filter == null
      ? mockPosts
      : mockPosts.where((p) => p.category == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final posts = _posts;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          const Text(
            'Media & Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Market news & education for Cambodia',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _Chips(
            selected: _filter,
            onSelect: (c) => setState(() => _filter = c),
          ),
          const SizedBox(height: 18),
          if (posts.isNotEmpty && _filter == null) ...[
            _FeaturedCard(post: posts.first),
            const SizedBox(height: 18),
            for (final p in posts.skip(1)) ...[
              _PostRow(post: p),
              const SizedBox(height: 14),
            ],
          ] else
            for (final p in posts) ...[
              _PostRow(post: p),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.selected, required this.onSelect});

  final PostCategory? selected;
  final ValueChanged<PostCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(PostCategory?, String)>[
      (null, 'All'),
      (PostCategory.news, 'News'),
      (PostCategory.article, 'Guides'),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (cat, label) = items[i];
          final sel = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/media/post', extra: post),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.surfaceMuted),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _CatPill(category: post.category),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Meta(post: post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/media/post', extra: post),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 92,
                  height: 92,
                  color: AppColors.surfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CatPill(category: post.category),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Meta(post: post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${post.source} · ${post.date} · ${post.readMins} min read',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        color: AppColors.textSecondary.withValues(alpha: 0.9),
      ),
    );
  }
}

class _CatPill extends StatelessWidget {
  const _CatPill({required this.category});

  final PostCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: category.color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
