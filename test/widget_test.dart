import 'package:flutter_test/flutter_test.dart';
import 'package:smart_fert/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFertApp());
    expect(find.text('SmartFert'), findsOneWidget);
  });
}
