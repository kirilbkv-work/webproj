import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

/// Обложка товара.
///
/// Прототип не использует внешние изображения, поэтому обложка строится
/// из фирменных цветов товара и его монограммы.
class ItemCover extends StatelessWidget {
  const ItemCover({super.key, required this.item, this.aspectRatio = 4 / 3});

  final Item item;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(item.coverFrom), Color(item.coverTo)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      item.monogram,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: 56,
                        shadows: const [
                          Shadow(
                            color: Color(0x38000000),
                            blurRadius: 18,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 11,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.colorway.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF1C1917),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
