import 'package:flutter_test/flutter_test.dart';
import 'package:chess_strategy/main.dart';

void main() {
  testWidgets('Chess Strategy app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessStrategyApp());
    expect(find.text('CHESS'), findsOneWidget);
  });
}
