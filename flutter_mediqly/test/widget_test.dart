// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:flutter_mediqly/app.dart';
import 'package:flutter_mediqly/providers/navigation_provider.dart';
import 'package:flutter_mediqly/providers/app_state_provider.dart';
import 'package:flutter_mediqly/providers/health_twin_provider.dart';

void main() {
  testWidgets('App renders bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => HealthTwinProvider()),
        ],
        child: const MediqlyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MediqlyApp), findsOneWidget);
  });
}
