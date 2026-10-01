import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muhurtham/features/customer/home/presentation/pages/home_page.dart';
import 'package:muhurtham/features/halls/data/nearby_location.dart';
import 'package:muhurtham/theme/app_theme.dart';
import 'catalog_test.dart' as fixtures;

class FakeLocation implements LocationSource {
  FakeLocation({this.denied = false});
  final bool denied;
  int calls = 0;
  @override
  Future<LocationPoint> currentLocation() async {
    calls++;
    if (denied) {
      throw const LocationException(
        'Location permission was not granted. You can still filter by city.',
      );
    }
    return const LocationPoint(17.385, 78.4867);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> open(
    WidgetTester tester, {
    FakeLocation? location,
    Key? key,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: HomePage(key: key, locationSource: location),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  testWidgets('adding a venue persists its catalog entry and services', (
    tester,
  ) async {
    await open(tester);
    await tapVisible(tester, find.byKey(const Key('add-listing')));
    await tapVisible(tester, find.byKey(const Key('save-listing')));
    expect(find.text('This field is required'), findsWidgets);
    await fill(tester, 'listing-name', 'Test Rose Hall');
    await fill(tester, 'listing-city', 'Hyderabad');
    await fill(tester, 'listing-address', 'Test garden road');
    await fill(tester, 'listing-capacity', '500');
    await fill(tester, 'listing-price', '100000');
    await fill(tester, 'listing-latitude', '17.385');
    await fill(tester, 'listing-longitude', '78.4867');
    await tapVisible(tester, find.byKey(const Key('save-listing')));
    expect(find.text('Test Rose Hall'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    final data = jsonDecode(preferences.getString('local_catalog_v1')!) as List;
    expect(data.single['name'], 'Test Rose Hall');
    expect(data.single['isSample'], isFalse);
    await open(tester, key: const ValueKey('reopened-catalog'));
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Test Rose Hall'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'nearby uses location only after tapping and changes with radius',
    (tester) async {
      final near = fixtures.listing(id: 800, name: 'Near Test Hall');
      final farther = fixtures.listing(
        id: 801,
        name: 'Farther Test Hall',
        latitude: 17.685,
      );
      SharedPreferences.setMockInitialValues({
        'local_catalog_v1': jsonEncode([near.toJson(), farther.toJson()]),
      });
      final location = FakeLocation();
      await open(tester, location: location);
      expect(location.calls, 0);
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('use-location')));
      expect(location.calls, 1);
      expect(find.text('Near Test Hall'), findsOneWidget);
      expect(find.text('Farther Test Hall'), findsNothing);
      expect(find.text('Royal Palace Convention'), findsNothing);
      await tapVisible(tester, find.byKey(const Key('nearby-radius')));
      await tester.tap(find.text('Within 50 km').last);
      await tester.pumpAndSettle();
      expect(find.text('Farther Test Hall'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('denied location keeps city browsing usable', (tester) async {
    final location = FakeLocation(denied: true);
    await open(tester, location: location);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('use-location')));
    expect(
      find.text(
        'Location permission was not granted. You can still filter by city.',
      ),
      findsOneWidget,
    );
    expect(find.text('Royal Palace Convention'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('city-filter-all')));
    await tester.tap(find.text('Tirupati').last);
    await tester.pumpAndSettle();
    expect(find.text('Emerald Palace'), findsOneWidget);
    expect(find.text('Royal Palace Convention'), findsNothing);
  });

  testWidgets(
    'venue booking saves an unsent request and cancellation survives reload',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('request-listing-1')));
      await fill(tester, 'booking-name', 'Test Planner');
      await fill(tester, 'booking-contact', 'test@example.com');
      await fill(tester, 'booking-guests', '1501');
      await tapVisible(tester, find.byKey(const Key('save-booking')));
      expect(find.text('This venue holds up to 1500 guests'), findsOneWidget);
      await fill(tester, 'booking-guests', '100');
      await tapVisible(tester, find.byKey(const Key('booking-date')));
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      final dateInput = find.descendant(
        of: find.byType(InputDatePickerFormField),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(
        dateInput,
        DateFormat.yMd(
          'en_US',
        ).format(DateTime.now().add(const Duration(days: 2))),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('save-booking')));
      expect(find.text('Saved locally · Not sent'), findsOneWidget);
      final preferences = await SharedPreferences.getInstance();
      final data =
          jsonDecode(preferences.getString('booking_requests_v1')!) as List;
      expect(data.single['venueId'], 1);
      expect(data.single['guests'], 100);
      final id = data.single['id'] as String;
      await tapVisible(tester, find.byKey(Key('cancel-booking-$id')));
      expect(find.text('Cancelled locally'), findsOneWidget);
      await open(tester, key: const ValueKey('reopened-bookings'));
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled locally'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a wedding service opens its own booking form', (tester) async {
    await open(tester);
    await tapVisible(tester, find.text('Photography'));
    await tapVisible(tester, find.text('Request this service'));
    final service = tester.widget<DropdownButtonFormField<String>>(
      find.byKey(const Key('booking-service')),
    );
    expect(service.initialValue, 'photography');
    expect(find.byKey(const Key('booking-provider-name')), findsOneWidget);
  });
}
