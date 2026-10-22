import 'package:flutter_test/flutter_test.dart';
import 'package:awarescroll_app/main.dart';

void main() {
  testWidgets('AwareScrollApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AwareScrollApp());
    expect(find.text('AwareScroll AI'), findsWidgets);
  });
}
