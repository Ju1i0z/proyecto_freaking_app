import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freaking/main.dart';

void main() {
  // 1. Inicializa el binding de pruebas
  TestWidgetsFlutterBinding.ensureInitialized();

  // 2. Crea un almacén de prefs en memoria para las pruebas
  SharedPreferences.setMockInitialValues({
    'onboarding': false,
    'stripeCustomerId': '',
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final onboarding = prefs.getBool('onboarding') ?? false;
    final stripeCustomerId = prefs.getString('stripeCustomerId') ?? '';

    // 3. Construye la app
    await tester.pumpWidget(
      MyApp(
        onboarding: onboarding,
        stripeCustomerId: stripeCustomerId,
      ),
    );

    // 4. Verificaciones
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}

