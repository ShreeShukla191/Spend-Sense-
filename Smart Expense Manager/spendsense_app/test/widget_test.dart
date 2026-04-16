import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spendsense_app/main.dart';
import 'package:spendsense_app/providers/auth_provider.dart';

void main() {
  testWidgets('SpendSense App bootstraps correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const SpendSenseApp(),
      ),
    );

    // Initial render shows CircularProgressIndicator or LoginScreen
    expect(find.byType(SpendSenseApp), findsOneWidget);
  });
}
