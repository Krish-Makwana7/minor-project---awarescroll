import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awarescroll_app/main.dart';

void main() {
  testWidgets('AwareScrollApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_logged_in': true,
      'has_completed_onboarding': true,
      'student_name': 'Krish Makwana',
      'student_email': 'krish@gmail.com',
    });
    await tester.pumpWidget(const AwareScrollApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('AWARESCROLL'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
