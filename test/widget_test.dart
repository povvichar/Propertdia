import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:propertdia/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PropertdiaApp()));
    expect(find.text('PROPERTDIA'), findsOneWidget);
    expect(find.text('Grow your investment'), findsOneWidget);
  });
}
