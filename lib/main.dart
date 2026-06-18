import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'shared/utils/l10n_text.dart' as l10n_text;

void main() {
  runApp(const ProviderScope(child: PropertdiaApp()));
}

class PropertdiaApp extends ConsumerWidget {
  const PropertdiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    // Keep the context-free mirror used by mock-data getters in sync.
    l10n_text.currentLanguage = lang;

    return MaterialApp.router(
      title: 'PROPERTDIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: lang == AppLanguage.khmer
          ? const Locale('km')
          : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
