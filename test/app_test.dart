import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muhurtham/app/app.dart';
import 'package:muhurtham/features/customer/home/presentation/pages/home_page.dart';
import 'package:muhurtham/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openHome(WidgetTester tester, {Key? key}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomePage(key: key),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dark pink splash navigates to the home screen', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('A little magic. A lifetime of love.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('Let’s make it unforgettable.'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('search filters venues by city and handles empty results', (
    tester,
  ) async {
    await openHome(tester);
    await tester.enterText(find.byKey(const Key('wedding-search')), 'Tirupati');
    await tester.pumpAndSettle();
    expect(find.text('Emerald Palace'), findsOneWidget);
    expect(find.text('Royal Palace Convention'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('wedding-search')),
      'no-match-123',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matches just yet'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Big dreams.\nBeautiful beginnings.'), findsOneWidget);
  });

  testWidgets('venue hearts update the shortlist and survive reopening', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save-venue-1')));
    await tester.tap(find.byKey(const Key('save-venue-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Royal Palace Convention'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('saved_venues'), ['1']);

    await openHome(tester, key: const ValueKey('reopened'));
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Royal Palace Convention'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('save-venue-1')));
    await tester.tap(find.byKey(const Key('save-venue-1')));
    await tester.pumpAndSettle();
    expect(find.text('Love it? Save it.'), findsOneWidget);
    expect(preferences.getStringList('saved_venues'), isEmpty);
  });

  testWidgets('service icons open tips and the planner tracks completion', (
    tester,
  ) async {
    await openHome(tester);
    await tester.ensureVisible(find.text('Photography'));
    await tester.tap(find.text('Photography'));
    await tester.pumpAndSettle();
    expect(find.text('A little planning tip'), findsOneWidget);
    await tester.tap(find.text('Add to my plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My plan'));
    await tester.pumpAndSettle();
    expect(find.text('0 of 1 details complete'), findsOneWidget);
    await tester.tap(find.byKey(const Key('complete-photography')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 details complete'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('planned_services'), ['photography']);
    expect(preferences.getStringList('completed_services'), ['photography']);

    await openHome(tester, key: const ValueKey('reopened-plan'));
    await tester.tap(find.text('My plan'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 details complete'), findsOneWidget);
    await tester.tap(find.byKey(const Key('remove-plan-photography')));
    await tester.pumpAndSettle();
    expect(find.text('Every beautiful day starts somewhere'), findsOneWidget);
    expect(preferences.getStringList('completed_services'), isEmpty);
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1280, 900),
  ]) {
    testWidgets('home and navigation fit at ${size.width} pixels', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await openHome(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Photography'));
      expect(tester.takeException(), isNull);
      for (final tab in ['Explore', 'Saved', 'Bookings', 'My plan', 'Home']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
