import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';

/// Статус заказа в виде цветной метки.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (status) {
      OrderStatus.inProgress => (palette.infoTint, palette.info),
      OrderStatus.arrived => (palette.brandTint, palette.brand),
      OrderStatus.canceled => (palette.dangerTint, palette.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
