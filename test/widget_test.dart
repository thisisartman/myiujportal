import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myiuj_portal/app.dart';
import 'package:myiuj_portal/providers/alerts_provider.dart';
import 'package:myiuj_portal/providers/directory_provider.dart';
import 'package:myiuj_portal/widgets/dashboard/alerts_widget.dart';
import 'package:myiuj_portal/models/alert_item.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyIUJApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AlertsWidget shows injected alerts', (tester) async {
    final testAlert = AlertItem(
      id: 'test1',
      title: 'Test Alert',
      body: 'Body text',
      date: 'Apr 6',
      mailingList: 'all',
      severity: AlertSeverity.info,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith((ref) => [testAlert]),
        ],
        child: const MaterialApp(home: Scaffold(body: AlertsWidget())),
      ),
    );
    expect(find.text('Test Alert'), findsOneWidget);
  });

  testWidgets('directoryFilterProvider defaults to All', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(capturedRef.read(directoryFilterProvider), 'All');
  });
}
