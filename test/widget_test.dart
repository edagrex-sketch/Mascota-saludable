import 'package:flutter_test/flutter_test.dart';
import 'package:mascota_saludable/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MascotaSaludableApp());

    // Verify the splash screen shows the app name
    expect(find.text('Mascota Saludable'), findsOneWidget);
    expect(find.text('Cuida de los que más te importan'), findsOneWidget);

    // Advance the splash timer to avoid pending timer assertion
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
