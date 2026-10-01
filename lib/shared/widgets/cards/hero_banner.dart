import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'glass_card.dart';
import '../common/brand_mark.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, this.onBook});
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      radius: 28,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x33714A64), Color(0x33564161), Color(0x22403451)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showArt = constraints.maxWidth > 430;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                'YOUR HAPPILY EVER AFTER',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Big dreams.\nBeautiful beginnings.',
                          style: TextStyle(
                            fontSize: 30,
                            height: 1.18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'All the little things for your big day,\ntogether in one lovely place.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: onBook,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: Text('Explore venues')),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showArt)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _WeddingMotif(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WeddingMotif extends StatelessWidget {
  const _WeddingMotif();
  @override
  Widget build(BuildContext context) => const BrandMark(size: 160);
}
