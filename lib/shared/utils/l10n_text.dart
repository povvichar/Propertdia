import '../providers/app_providers.dart';

/// Mirror of [languageProvider]'s value for use in places that have no
/// `BuildContext`/`WidgetRef` — chiefly mock-data getters. Kept in sync by
/// `PropertdiaApp.build` (which watches the provider), so it is always current
/// for the rebuild that a language change triggers.
AppLanguage currentLanguage = AppLanguage.english;

/// A bilingual string for mocked content. Resolves against [currentLanguage].
class L10nText {
  const L10nText(this.en, this.km);

  final String en;
  final String km;

  String get value =>
      currentLanguage == AppLanguage.khmer ? km : en;

  @override
  String toString() => value;
}
