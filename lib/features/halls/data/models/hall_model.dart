class HallModel {
  const HallModel({
    required this.id,
    required this.name,
    required this.city,
    required this.image,
    required this.rating,
    required this.capacity,
    required this.price,
    required this.featured,
    this.address = '',
    this.latitude,
    this.longitude,
    this.serviceIds = const ['venues'],
    this.isSample = true,
  });

  final int id;
  final String name;
  final String city;
  final String image;
  final double rating;
  final int capacity;
  final double price;
  final bool featured;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> serviceIds;
  final bool isSample;
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isVenue => serviceIds.contains('venues');

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'image': image,
    'rating': rating,
    'capacity': capacity,
    'price': price,
    'featured': featured,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'serviceIds': serviceIds,
    'isSample': isSample,
  };

  factory HallModel.fromJson(Map<String, dynamic> json) {
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    final price = (json['price'] as num).toDouble();
    final capacity = json['capacity'] as int;
    final name = (json['name'] as String).trim();
    final city = (json['city'] as String).trim();
    final services = (json['serviceIds'] as List).cast<String>();
    if (name.isEmpty ||
        city.isEmpty ||
        capacity < 0 ||
        !price.isFinite ||
        price < 0 ||
        services.isEmpty ||
        (latitude == null) != (longitude == null) ||
        (latitude != null && (!latitude.isFinite || latitude.abs() > 90)) ||
        (longitude != null && (!longitude.isFinite || longitude.abs() > 180))) {
      throw const FormatException('Invalid listing');
    }
    return HallModel(
      id: json['id'] as int,
      name: name,
      city: city,
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      capacity: capacity,
      price: price,
      featured: json['featured'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
      serviceIds: List.unmodifiable(services),
      isSample: json['isSample'] as bool? ?? false,
    );
  }
}
