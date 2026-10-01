import 'package:flutter/material.dart';

class WeddingService {
  const WeddingService({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.tip,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String tip;
}

const weddingServices = [
  WeddingService(
    id: 'venues',
    title: 'Venues',
    icon: Icons.other_houses_outlined,
    color: Color(0xFFF0ACC8),
    description: 'Find a beautiful setting for your celebration.',
    tip: 'Start with your guest count, preferred city, and wedding date.',
  ),
  WeddingService(
    id: 'photography',
    title: 'Photography',
    icon: Icons.photo_camera_outlined,
    color: Color(0xFFC5AFF0),
    description: 'Keep every little moment, forever.',
    tip: 'Choose a style you love and ask to see a complete wedding gallery.',
  ),
  WeddingService(
    id: 'catering',
    title: 'Catering',
    icon: Icons.restaurant_menu_rounded,
    color: Color(0xFFF3C198),
    description: 'A menu your loved ones will remember.',
    tip: 'Plan a tasting and discuss dietary needs before deciding.',
  ),
  WeddingService(
    id: 'decor',
    title: 'Décor',
    icon: Icons.local_florist_outlined,
    color: Color(0xFFA5D9C3),
    description: 'Turn your vision into a beautiful celebration.',
    tip: 'Gather a mood board with your favourite colours and flowers.',
  ),
  WeddingService(
    id: 'jewellery',
    title: 'Jewellery',
    icon: Icons.diamond_outlined,
    color: Color(0xFFE8CC91),
    description: 'The finishing touches to your special day.',
    tip: 'Match your jewellery to your outfit and schedule a fitting.',
  ),
  WeddingService(
    id: 'beauty',
    title: 'Beauty',
    icon: Icons.face_retouching_natural_outlined,
    color: Color(0xFFF1ABCB),
    description: 'Look and feel like your most beautiful self.',
    tip: 'Book a trial and share your ceremony timing with your artist.',
  ),
  WeddingService(
    id: 'music',
    title: 'Music',
    icon: Icons.music_note_outlined,
    color: Color(0xFFAAC8F5),
    description: 'Set the mood, from your entrance to the last dance.',
    tip: 'Make a must-play list and check the venue’s sound restrictions.',
  ),
  WeddingService(
    id: 'invitations',
    title: 'Invitations',
    icon: Icons.mark_email_unread_outlined,
    color: Color(0xFFDBABC1),
    description: 'A thoughtful first glimpse of your celebration.',
    tip: 'Confirm dates, addresses, and RSVP details before printing.',
  ),
  WeddingService(
    id: 'outfits',
    title: 'Outfits',
    icon: Icons.checkroom_outlined,
    color: Color(0xFFD0B2DF),
    description: 'Find the outfit that feels perfectly you.',
    tip: 'Allow time for alterations and try your outfit with accessories.',
  ),
  WeddingService(
    id: 'transport',
    title: 'Transport',
    icon: Icons.directions_car_outlined,
    color: Color(0xFFA7D0DE),
    description: 'Make every arrival feel effortless.',
    tip: 'Arrange transport for the couple and guests who need a ride.',
  ),
  WeddingService(
    id: 'stays',
    title: 'Guest stays',
    icon: Icons.bed_outlined,
    color: Color(0xFFE3B899),
    description: 'A warm welcome for your out-of-town guests.',
    tip: 'Look for rooms near your venue and ask about group rates.',
  ),
  WeddingService(
    id: 'gifts',
    title: 'Gifts',
    icon: Icons.redeem_outlined,
    color: Color(0xFFE8A5C3),
    description: 'Little thank-yous, filled with love.',
    tip: 'Choose meaningful favours that are easy for guests to take home.',
  ),
];
