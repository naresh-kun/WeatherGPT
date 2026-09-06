import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherGptApp());
    await tester.pump();

    expect(find.text('WeatherGPT'), findsOneWidget);
    expect(find.text('Your Intelligent Weather Assistant'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
