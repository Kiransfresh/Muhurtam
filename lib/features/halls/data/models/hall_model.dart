class HallModel {
  final int id;
  final String name;
  final String city;
  final String image;
  final double rating;
  final int capacity;
  final double price;
  final bool featured;

  const HallModel({
    required this.id,
    required this.name,
    required this.city,
    required this.image,
    required this.rating,
    required this.capacity,
    required this.price,
    required this.featured,
  });
}
