import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myiuj_portal/app.dart';
import 'package:myiuj_portal/providers/alerts_provider.dart';
import 'package:myiuj_portal/providers/directory_provider.dart';
import 'package:myiuj_portal/widgets/dashboard/alerts_widget.dart';
import 'package:myiuj_portal/models/alert_item.dart';
import 'package:myiuj_portal/data/mock_data.dart';
import 'package:go_router/go_router.dart';
import 'package:myiuj_portal/widgets/layout/top_nav.dart';

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

  testWidgets('TopNav shows warning report icon', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: TopNav()),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byTooltip('Report an Issue'), findsOneWidget);
  });

  test('kFinancialStatements has 6 unique, correctly-formatted entries in chronological order', () {
    expect(kFinancialStatements.length, 6);
    // No duplicates
    expect(kFinancialStatements.toSet().length, kFinancialStatements.length);
    // Format: 'Month YYYY Statement'
    final pattern = RegExp(r'^\w+ \d{4} Statement$');
    for (final s in kFinancialStatements) {
      expect(pattern.hasMatch(s), isTrue, reason: '$s does not match expected format');
    }
    // Chronological order (list is ordered oldest-first)
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    for (int i = 1; i < kFinancialStatements.length; i++) {
      final prev = kFinancialStatements[i - 1].split(' ');
      final curr = kFinancialStatements[i].split(' ');
      final prevYear = int.parse(prev[1]);
      final currYear = int.parse(curr[1]);
      final prevMonth = months.indexOf(prev[0]);
      final currMonth = months.indexOf(curr[0]);
      final prevOrd = prevYear * 12 + prevMonth;
      final currOrd = currYear * 12 + currMonth;
      expect(currOrd, greaterThan(prevOrd),
          reason: '${kFinancialStatements[i]} should come after ${kFinancialStatements[i-1]}');
    }
  });
}
