import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';

class HallCard extends StatelessWidget {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int guests;
  final double price;
  final bool featured;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const HallCard({
    super.key,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.guests,
    required this.price,
    this.featured = false,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: name,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: imageUrl.isEmpty
                          ? Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF7B2CBF),
                                    Color(0xFFFF4FA3),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.location_city,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ),
                            )
                          : Image.network(imageUrl, fit: BoxFit.cover),
                    ),

                    if (featured)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFFFE082)],
                            ),
                          ),
                          child: const Text(
                            "FEATURED",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      right: 16,
                      top: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.pink.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(rating.toString()),

                      const Spacer(),

                      const Icon(Icons.people, size: 18),
                      const SizedBox(width: 5),
                      Text("$guests Guests"),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Text(
                        "₹${price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Color(0xFF7B2CBF),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 130,
                        child: PrimaryButton(text: "Book", onPressed: onBook),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
