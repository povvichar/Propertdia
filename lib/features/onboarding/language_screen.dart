import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/primary_button.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _TranslateMark(),
              const SizedBox(height: 24),
              Text(
                'ជ្រើសរើសភាសា',
                style: GoogleFonts.notoSansKhmer(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _LanguageCard(
                      flagUrl: 'https://flagcdn.com/w80/kh.png',
                      label: 'ភាសាខ្មែរ',
                      khmer: true,
                      selected: selected == AppLanguage.khmer,
                      onTap: () => ref
                          .read(languageProvider.notifier)
                          .state = AppLanguage.khmer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LanguageCard(
                      flagUrl: 'https://flagcdn.com/w80/gb.png',
                      label: 'English',
                      selected: selected == AppLanguage.english,
                      onTap: () => ref
                          .read(languageProvider.notifier)
                          .state = AppLanguage.english,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              PrimaryButton(
                label: 'Continue',
                onPressed: () => context.go('/onboarding'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslateMark extends StatelessWidget {
  const _TranslateMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'ខ',
                style: GoogleFonts.notoSansKhmer(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flagUrl,
    required this.label,
    required this.selected,
    required this.onTap,
    this.khmer = false,
  });

  final String flagUrl;
  final String label;
  final bool selected;
  final bool khmer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            children: [
              ClipOval(
                child: Image.network(
                  flagUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: khmer
                    ? GoogleFonts.notoSansKhmer(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )
                    : const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
