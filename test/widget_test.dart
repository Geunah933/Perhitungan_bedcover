import 'package:flutter_test/flutter_test.dart';
import 'package:gilang_mandiri/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GilangMandiriApp());
    expect(find.text('Gilang Mandiri'), findsOneWidget);
  });
}
