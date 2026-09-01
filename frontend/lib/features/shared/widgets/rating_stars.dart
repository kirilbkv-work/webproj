import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

/// rating as five stars plus the numeric value
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.count = 0,
    this.showValue = true,
    this.starSize = 16,
  });

  /// average rating, 0 to 5
  final double value;

  /// number of reviews behind the average
  final int count;
  final bool showValue;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fraction = (value / 5).clamp(0.0, 1.0);

    final stars = Stack(
      children: [
        _StarRow(color: palette.lineStrong, size: starSize),
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: _StarRow(color: palette.accent, size: starSize),
          ),
        ),
      ],
    );

    if (!showValue) {
      return Semantics(
        label: 'Rated ${value.toStringAsFixed(1)} out of 5',
        child: stars,
      );
    }

    return Semantics(
      label: count > 0
          ? 'Rated ${value.toStringAsFixed(1)} out of 5 from $count reviews'
          : 'No reviews yet',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          stars,
          const SizedBox(width: 8),
          if (count > 0) ...[
            Text(
              value.toStringAsFixed(1),
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
            const SizedBox(width: 4),
            Text('($count)', style: context.texts.bodySmall),
          ] else
            Text('No reviews yet', style: context.texts.bodySmall),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        5,
        (_) => Icon(Icons.star_rounded, size: size, color: color),
      ),
    );
  }
}
