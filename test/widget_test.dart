import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rastro_x/app.dart';

void main() {
  testWidgets('Rastro X app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RastroXApp(),
      ),
    );

    expect(find.text('RASTRO X'), findsOneWidget);
    expect(find.text('INICIAR EL JUEGO'), findsOneWidget);
  });
}
