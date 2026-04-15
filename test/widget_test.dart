import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orientacion/app.dart';

void main() {
  testWidgets('Orientación app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OrientacionApp()));

    expect(find.text('Bienvenido a Orientación Escolar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
