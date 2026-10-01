import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muhurtham/shared/data/local_catalog.dart';
import 'package:muhurtham/features/bookings/data/booking_request.dart';
import 'package:muhurtham/features/customer/home/data/wedding_services.dart';
import 'package:muhurtham/features/halls/data/models/hall_model.dart';
import 'package:muhurtham/features/halls/data/nearby_location.dart';

HallModel listing({
  int id = 100,
  String name = 'Test Rose Hall',
  double? latitude = 17.385,
  double? longitude = 78.4867,
  bool sample = false,
}) => HallModel(
  id: id,
  name: name,
  city: 'Hyderabad',
  address: 'Test locality',
  image: '',
  rating: 0,
  capacity: 500,
  price: 100000,
  featured: false,
  latitude: latitude,
  longitude: longitude,
  serviceIds: const ['venues', 'photography'],
  isSample: sample,
);

BookingRequest request({
  String id = 'test-request',
  String service = 'venues',
  int? venueId = 100,
  int guests = 100,
  DateTime? date,
  String provider = 'Test Rose Hall',
}) => BookingRequest(
  id: id,
  serviceId: service,
  venueId: venueId,
  providerName: provider,
  eventDate: date ?? DateTime.now().add(const Duration(days: 2)),
  guests: guests,
  customerName: 'Test Planner',
  contact: 'test@example.com',
  notes: 'Test request',
  createdAt: DateTime.now(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalCatalog catalog;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    catalog = LocalCatalog(await SharedPreferences.getInstance())..load();
  });

  test('added listings round-trip with services and coordinates', () async {
    await catalog.addListing(listing());
    final restored = LocalCatalog(catalog.preferences)..load();
    expect(restored.addedListings.single.name, 'Test Rose Hall');
    expect(restored.addedListings.single.serviceIds, ['venues', 'photography']);
    expect(restored.addedListings.single.latitude, 17.385);
    expect(restored.addedListings.single.isSample, isFalse);
    expect(restored.listings.first.id, 100);
    expect(
      jsonDecode(catalog.preferences.getString('local_catalog_v1')!),
      hasLength(1),
    );
  });

  test('duplicate listings cannot overwrite the catalog', () async {
    await catalog.addListing(listing());
    await expectLater(
      catalog.addListing(listing(id: 101, name: 'test rose hall')),
      throwsA(isA<CatalogException>()),
    );
    expect(catalog.addedListings, hasLength(1));
  });

  test(
    'nearby results sort by actual distance and exclude samples and missing coordinates',
    () {
      final venues = [
        listing(id: 101, latitude: 17.40),
        listing(id: 102, latitude: 18.40),
        listing(id: 103, latitude: null, longitude: null),
        listing(id: 104, sample: true),
        listing(id: 105),
      ];
      final result = nearbyListings(
        venues,
        const LocationPoint(17.385, 78.4867),
        25,
      );
      expect(result.map((venue) => venue.id), [105, 101]);
      expect(
        distanceKm(const LocationPoint(17.385, 78.4867), result.first),
        closeTo(0, 0.001),
      );
      expect(
        distanceKm(const LocationPoint(17.385, 78.4867), result.last),
        greaterThan(1),
      );
    },
  );

  test('booking requests and cancellation persist across reloads', () async {
    await catalog.addListing(listing());
    await catalog.addRequest(request());
    var restored = LocalCatalog(catalog.preferences)..load();
    expect(restored.requests.single.venueId, 100);
    expect(restored.requests.single.cancelled, isFalse);
    await restored.cancelRequest('test-request');
    restored = LocalCatalog(catalog.preferences)..load();
    expect(restored.requests.single.cancelled, isTrue);
  });

  test(
    'duplicate active requests are rejected, cancelled ones may be recreated',
    () async {
      await catalog.addListing(listing());
      final first = request();
      await catalog.addRequest(first);
      await expectLater(
        catalog.addRequest(
          request(
            id: 'second',
            date: first.eventDate,
            provider: 'test rose hall',
          ),
        ),
        throwsA(isA<CatalogException>()),
      );
      await catalog.cancelRequest(first.id);
      await catalog.addRequest(request(id: 'second', date: first.eventDate));
      expect(catalog.requests, hasLength(2));
    },
  );

  test(
    'past dates, excessive guests, and unavailable services do not save requests',
    () async {
      await catalog.addListing(listing());
      await expectLater(
        catalog.addRequest(
          request(date: DateTime.now().subtract(const Duration(days: 2))),
        ),
        throwsA(isA<CatalogException>()),
      );
      await expectLater(
        catalog.addRequest(request(guests: 501)),
        throwsA(isA<CatalogException>()),
      );
      await expectLater(
        catalog.addRequest(request(service: 'music')),
        throwsA(isA<CatalogException>()),
      );
      expect(catalog.requests, isEmpty);
    },
  );

  test(
    'every wedding service can have a local request for a named provider',
    () async {
      for (final service in weddingServices) {
        await catalog.addRequest(
          request(id: service.id, service: service.id, venueId: null),
        );
      }
      expect(
        catalog.requests.map((request) => request.serviceId).toSet(),
        weddingServices.map((service) => service.id).toSet(),
      );
    },
  );

  test('invalid listing coordinates are rejected when restoring data', () {
    final data = listing().toJson()..['latitude'] = 91;
    expect(() => HallModel.fromJson(data), throwsFormatException);
  });
}
