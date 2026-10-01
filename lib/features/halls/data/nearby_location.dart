import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'models/hall_model.dart';

class LocationPoint {
  const LocationPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

abstract class LocationSource {
  Future<LocationPoint> currentLocation();
}

class DeviceLocationSource implements LocationSource {
  @override
  Future<LocationPoint> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Location is turned off. Choose a city or enable location services.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission was not granted. You can still filter by city.',
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationPoint(position.latitude, position.longitude);
    } catch (_) {
      throw const LocationException(
        'Could not get your location. Try again or choose a city.',
      );
    }
  }
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

double distanceKm(LocationPoint origin, HallModel venue) {
  if (!venue.hasCoordinates) return double.infinity;
  double radians(double degrees) => degrees * math.pi / 180;
  final lat = radians(venue.latitude! - origin.latitude);
  final lon = radians(venue.longitude! - origin.longitude);
  final a =
      math.pow(math.sin(lat / 2), 2) +
      math.cos(radians(origin.latitude)) *
          math.cos(radians(venue.latitude!)) *
          math.pow(math.sin(lon / 2), 2);
  return 6371 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
}

List<HallModel> nearbyListings(
  List<HallModel> venues,
  LocationPoint location,
  double radiusKm,
) {
  final nearby = venues
      .where(
        (venue) =>
            !venue.isSample &&
            venue.hasCoordinates &&
            distanceKm(location, venue) <= radiusKm,
      )
      .toList();
  nearby.sort(
    (a, b) => distanceKm(location, a).compareTo(distanceKm(location, b)),
  );
  return nearby;
}
