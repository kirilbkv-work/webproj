import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/reviews/reviews_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/rating_stars.dart';
import '../shared/widgets/ui_kit.dart';

/// Порог перехода макета в одну колонку.
const double _narrowWidth = 760;

/// Минимальная ширина колонки в сетке отзывов.
const double _minCardWidth = 320;

const List<int> _ratingFilters = [5, 4, 3, 2, 1];

/// Все отзывы покупателей: сводная оценка, фильтры и сетка карточек.
///
/// Страница открыта без авторизации — задание разрешает читать чужие
/// отзывы всем посетителям.
class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Head(state: state),
              const SizedBox(height: 28),
              _FiltersPanel(state: state),
              const SizedBox(height: 24),
              if (state.rows.isEmpty)
                EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'No reviews match these filters',
                  message: 'Try another item or rating.',
                  action: FilledButton(
                    onPressed: () => _clearFilters(context),
                    child: const Text('Clear filters'),
                  ),
                )
              else
                _ReviewGrid(rows: state.rows),
            ],
          ),
        );
      },
    );
  }
}

void _clearFilters(BuildContext context) {
  context.read<ReviewsBloc>().add(const ReviewsFiltersCleared());
}

/// Заголовок страницы и сводка по всем отзывам.
class _Head extends StatelessWidget {
  const _Head({required this.state});

  final ReviewsState state;

  @override
  Widget build(BuildContext context) {
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Community'),
        const SizedBox(height: 8),
        Text('Customer reviews', style: context.texts.displayMedium),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Every review comes from a customer who ordered the item and '
            'rated the delivered order. Reading reviews does not require '
            'an account.',
            style: context.texts.bodyLarge,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _narrowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              intro,
              const SizedBox(height: 20),
              _Overview(state: state),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: intro),
            const SizedBox(width: 28),
            SizedBox(width: 360, child: _Overview(state: state)),
          ],
        );
      },
    );
  }
}

/// Средняя оценка магазина и общее число отзывов.
class _Overview extends StatelessWidget {
  const _Overview({required this.state});

  final ReviewsState state;

  @override
  Widget build(BuildContext context) {
    return Panel(
      flat: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            state.averageRating.toStringAsFixed(1),
            style: context.texts.displayMedium,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // На узком экране строка звёзд с числами не помещается
                // целиком — сжимаем её вместо переполнения.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RatingStars(
                    value: state.averageRating,
                    count: state.totalCount,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.totalCount} reviews across the collection',
                  style: context.texts.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Фильтры по товару и оценке.
class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({required this.state});

  final ReviewsState state;

  @override
  Widget build(BuildContext context) {
    final itemField = _Field(
      label: 'Item',
      child: DropdownButtonFormField<String?>(
        value: state.itemFilter,
        isExpanded: true,
        onChanged: (value) =>
            context.read<ReviewsBloc>().add(ReviewsItemFilterChanged(value)),
        items: [
          const DropdownMenuItem<String?>(child: Text('All items')),
          for (final item in state.items)
            DropdownMenuItem<String?>(
              value: item.id,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );

    final ratingField = _Field(
      label: 'Rating',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final rating in _ratingFilters)
            SelectableChip(
              label: '$rating ★',
              selected: state.ratingFilter == rating,
              onTap: () => context.read<ReviewsBloc>().add(
                ReviewsRatingFilterToggled(rating),
              ),
            ),
        ],
      ),
    );

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _narrowWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemField,
                    const SizedBox(height: 18),
                    ratingField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: itemField),
                  const SizedBox(width: 24),
                  Expanded(child: ratingField),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${state.rows.length} reviews shown',
                  style: context.texts.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => _clearFilters(context),
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Подпись над полем фильтра.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: context.palette.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Сетка карточек отзывов: на широком экране 2–3 колонки, на узком одна.
class _ReviewGrid extends StatelessWidget {
  const _ReviewGrid({required this.rows});

  final List<ReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 20.0;
        final columns = ((constraints.maxWidth + gap) / (_minCardWidth + gap))
            .floor()
            .clamp(1, 3);
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final row in rows)
              SizedBox(
                width: width,
                child: _ReviewCard(row: row),
              ),
          ],
        );
      },
    );
  }
}

/// Один отзыв: автор, дата, оценка, товар и текст.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.row});

  final ReviewRow row;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final texts = context.texts;
    final review = row.review;
    final item = row.item;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: review.authorName,
                        style: texts.bodyMedium?.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' · ${Formatters.shortDate(review.createdAt)}',
                        style: texts.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              RatingStars(value: review.rating.toDouble(), showValue: false),
            ],
          ),
          if (item != null) ...[
            const SizedBox(height: 10),
            _ItemLink(item: item),
          ],
          const SizedBox(height: 12),
          Text(
            review.comment.isEmpty
                ? 'Rated without a written comment.'
                : review.comment,
            style: review.comment.isEmpty
                ? texts.bodyMedium?.copyWith(color: palette.inkMuted)
                : texts.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Ссылка на карточку товара, к которому относится отзыв.
class _ItemLink extends StatelessWidget {
  const _ItemLink({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/catalog/${item.id}'),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: item.name,
                style: context.texts.bodyMedium?.copyWith(
                  color: palette.brandSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' · ${item.manufacturer}',
                style: context.texts.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
