import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { khmer, english }

/// Selected app language; persisted via SharedPreferences in a later phase.
final languageProvider =
    StateProvider<AppLanguage>((ref) => AppLanguage.english);

/// Index of the active bottom-navigation tab on the home shell.
final homeTabProvider = StateProvider<int>((ref) => 0);
