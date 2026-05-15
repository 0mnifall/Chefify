import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('renders chefify home sections', (tester) async {
    await tester.pumpWidget(const ChefifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.text('Weekly recipes in your inbox'), findsOneWidget);
  });
}
