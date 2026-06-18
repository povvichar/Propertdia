import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:propertdia/features/onboarding/splash_screen.dart';
import 'package:propertdia/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PropertdiaApp()));

    // The initial '/' route shows the splash screen with the brand logo
    // and a loading spinner (no text labels are rendered here).
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
