import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'item_cover.dart';
import 'rating_stars.dart';
import 'ui_kit.dart';

/// catalog card with every attribute the assignment asks for
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.stats});

  final Item item;
  final ReviewStats stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => context.go('/catalog/${item.id}'),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: palette.line),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemCover(item: item),
              const SizedBox(height: 14),
              Tag(item.type.label),
              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.headlineSmall?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.manufacturer} · Size ${item.size.label} · '
                '${Formatters.monthYear(item.productDate)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall,
              ),
              const SizedBox(height: 8),
              RatingStars(value: stats.average, count: stats.count),
              const Spacer(),
              const SizedBox(height: 12),
              Divider(color: palette.line, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    Formatters.moneyShort(item.price),
                    style: context.texts.titleLarge?.copyWith(
                      fontFamily: null,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View item →',
                    style: context.texts.bodySmall?.copyWith(
                      color: palette.brandSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
