import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/bookings/data/booking_request.dart';
import '../../features/halls/data/dummy_halls.dart';
import '../../features/halls/data/models/hall_model.dart';

class LocalCatalog {
  LocalCatalog(this.preferences);
  final SharedPreferences preferences;
  final List<HallModel> _added = [];
  final List<BookingRequest> _requests = [];
  List<HallModel> get listings => List.unmodifiable([..._added, ...dummyHalls]);
  List<HallModel> get addedListings => List.unmodifiable(_added);
  List<BookingRequest> get requests => List.unmodifiable(_requests);

  void load() {
    final listings = preferences.getString('local_catalog_v1');
    final requests = preferences.getString('booking_requests_v1');
    if (listings != null) {
      _added.addAll(
        (jsonDecode(listings) as List).map(
          (entry) =>
              HallModel.fromJson(Map<String, dynamic>.from(entry as Map)),
        ),
      );
    }
    if (requests != null) {
      _requests.addAll(
        (jsonDecode(requests) as List).map(
          (entry) =>
              BookingRequest.fromJson(Map<String, dynamic>.from(entry as Map)),
        ),
      );
    }
  }

  Future<void> addListing(HallModel listing) async {
    if (listings.any(
      (existing) =>
          existing.id == listing.id ||
          (existing.name.toLowerCase() == listing.name.toLowerCase() &&
              existing.city.toLowerCase() == listing.city.toLowerCase()),
    )) {
      throw const CatalogException(
        'This listing already exists in your catalog.',
      );
    }
    final next = [..._added, listing];
    final success = await preferences.setString(
      'local_catalog_v1',
      jsonEncode(next.map((venue) => venue.toJson()).toList()),
    );
    if (!success) {
      throw const CatalogException(
        'Could not save the listing. Please try again.',
      );
    }
    _added.add(listing);
  }

  Future<void> addRequest(BookingRequest request) async {
    final today = DateTime.now();
    if (request.eventDate.isBefore(
      DateTime(today.year, today.month, today.day),
    )) {
      throw const CatalogException('Choose today or a future event date.');
    }
    if (_requests.any(
      (existing) =>
          !existing.cancelled &&
          existing.serviceId == request.serviceId &&
          existing.providerName.trim().toLowerCase() ==
              request.providerName.trim().toLowerCase() &&
          existing.eventDate.year == request.eventDate.year &&
          existing.eventDate.month == request.eventDate.month &&
          existing.eventDate.day == request.eventDate.day,
    )) {
      throw const CatalogException(
        'You already have a request for this service, provider, and date.',
      );
    }
    final matches = listings.where((venue) => venue.id == request.venueId);
    if (request.venueId != null && matches.isEmpty) {
      throw const CatalogException('This listing is no longer in the catalog.');
    }
    if (matches.isNotEmpty) {
      final listing = matches.first;
      if (!listing.serviceIds.contains(request.serviceId)) {
        throw const CatalogException(
          'This listing does not offer the selected service.',
        );
      }
      if (request.serviceId == 'venues' &&
          listing.capacity > 0 &&
          request.guests > listing.capacity) {
        throw CatalogException(
          'This venue holds up to ${listing.capacity} guests.',
        );
      }
    }
    final next = [..._requests, request];
    await _writeRequests(next);
    _requests.add(request);
  }

  Future<void> cancelRequest(String id) async {
    final next = _requests
        .map((request) => request.id == id ? request.cancel() : request)
        .toList();
    await _writeRequests(next);
    _requests
      ..clear()
      ..addAll(next);
  }

  Future<void> _writeRequests(List<BookingRequest> requests) async {
    final success = await preferences.setString(
      'booking_requests_v1',
      jsonEncode(requests.map((request) => request.toJson()).toList()),
    );
    if (!success) {
      throw const CatalogException(
        'Could not save the request. Please try again.',
      );
    }
  }
}

class CatalogException implements Exception {
  const CatalogException(this.message);
  final String message;
  @override
  String toString() => message;
}
