import 'package:flutter/material.dart';

class PopularVendors extends StatelessWidget {
  const PopularVendors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) {
          return Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xffF3E5F5),
                child: Icon(Icons.camera_alt, color: Colors.purple.shade700),
              ),
              const SizedBox(height: 10),
              const Text("Photo"),
            ],
          );
        },
      ),
    );
  }
}
