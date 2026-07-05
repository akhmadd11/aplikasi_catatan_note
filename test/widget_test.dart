import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_catatan_note/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Basic smoke test — app initializes without throwing
    expect(find.byType(App), findsOneWidget);
  });
}
