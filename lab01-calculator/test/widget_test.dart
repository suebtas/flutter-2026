import 'package:flutter_test/flutter_test.dart';
import 'package:lab01_calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CalculatorApp());

    // Verify that our initial output is '0'.
    expect(find.text('0'), findsWidgets);

    // Tap the '1' button and trigger a frame.
    await tester.tap(find.text('1'));
    await tester.pump();

    // Verify that the output updated to '1'.
    expect(find.text('1'), findsWidgets);
  });
}
