import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/item_details/item_details_bloc.dart';
import '../../application/orders/orders_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/item_card.dart';
import '../shared/widgets/item_cover.dart';
import '../shared/widgets/rating_stars.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/widgets/ui_kit.dart';
import 'widgets/reserve_dialog.dart';

/// item page: attributes, reviews and the reserve dialog
class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemDetailsBloc, ItemDetailsState>(
      builder: (context, state) {
        final item = state.item;
        if (item == null) {
          return PageBody(
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Item not found',
              message:
                  'This item is not part of the collection. '
                  'It may have been removed.',
              action: FilledButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Back to catalog'),
              ),
            ),
          );
        }

        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Breadcrumb(name: item.name),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 900;
                  final cover = ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: narrow ? 380 : double.infinity,
                    ),
                    child: ItemCover(
                      item: item,
                      aspectRatio: narrow ? 4 / 3 : 3 / 4,
                    ),
                  );
                  final details = _Details(state: state, item: item);

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [cover, const SizedBox(height: 26), details],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: cover),
                      const SizedBox(width: 40),
                      Expanded(flex: 7, child: details),
                    ],
                  );
                },
              ),
              const SizedBox(height: 56),
              _ReviewsSection(state: state),
              if (state.related.isNotEmpty) ...[
                const SizedBox(height: 56),
                Text(
                  'More ${item.type.label.toLowerCase()}',
                  style: context.texts.headlineMedium,
                ),
                const SizedBox(height: 18),
                _RelatedGrid(items: state.related),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/catalog'),
          child: Text(
            'Catalog',
            style: context.texts.bodyMedium?.copyWith(
              color: context.palette.brandSoft,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('/', style: context.texts.bodySmall),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.state, required this.item});

  final ItemDetailsState state;
  final Item item;

  Future<void> _reserve(BuildContext context) async {
    final auth = context.read<AuthBloc>().state;
    if (!auth.isAuthenticated) {
      context.go(
        '/login?returnUrl=${Uri.encodeComponent('/catalog/${item.id}')}',
      );
      return;
    }
    final ordersBloc = context.read<OrdersBloc>();
    final draft = await ReserveDialog.show(
      context,
      item: item,
      defaultAddress: auth.user?.address ?? '',
    );
    if (draft == null) return;
    ordersBloc.add(OrderReserved(itemId: item.id, draft: draft));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final authenticated = context.watch<AuthBloc>().state.isAuthenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tag(item.type.label),
        const SizedBox(height: 10),
        Text(item.name, style: context.texts.displayMedium),
        const SizedBox(height: 10),
        RatingStars(
          value: state.stats.average,
          count: state.stats.count,
          starSize: 22,
        ),
        const SizedBox(height: 14),
        Text(
          Formatters.money(item.price),
          style: context.texts.displayMedium?.copyWith(
            fontFamily: null,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(item.description, style: context.texts.bodyLarge),
        const SizedBox(height: 20),
        Divider(color: palette.line, height: 1),
        const SizedBox(height: 20),
        SpecGrid(
          entries: [
            SpecEntry('Type', item.type.label),
            SpecEntry('Size', item.size.label),
            SpecEntry('Manufacturer', item.manufacturer),
            SpecEntry('Product date', Formatters.longDate(item.productDate)),
            SpecEntry('Material', item.material),
            SpecEntry('Colorway', item.colorway),
            SpecEntry(
              'Available sizes',
              item.availableSizes.map((size) => size.label).join(', '),
            ),
            SpecEntry('Price', Formatters.money(item.price)),
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: palette.line, height: 1),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => _reserve(context),
              child: Text(
                authenticated ? 'Reserve this item' : 'Sign in to reserve',
              ),
            ),
            OutlinedButton(
              onPressed: () => context.go('/catalog'),
              child: const Text('Back to catalog'),
            ),
          ],
        ),
        if (!authenticated) ...[
          const SizedBox(height: 16),
          const Notice(
            tone: NoticeTone.info,
            text:
                'Browsing and reading reviews is open to everyone. Reserving '
                'an item and using the Order Cart requires an account.',
          ),
        ],
        if (state.myOrders.isNotEmpty) ...[
          const SizedBox(height: 18),
          Panel(
            flat: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your orders for this item',
                  style: context.texts.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final order in state.myOrders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(status: order.status),
                        Text(
                          'Size ${order.size.label} · ${order.quantity} pc · '
                          'reserved ${Formatters.shortDate(order.reservedAt)}',
                          style: context.texts.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                  ),
                  onPressed: () => context.go('/cart'),
                  child: const Text('Open Order Cart'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.state});

  final ItemDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Feedback'),
        const SizedBox(height: 6),
        Text(
          'Reviews from customers who ordered this item',
          style: context.texts.headlineMedium,
        ),
        const SizedBox(height: 18),
        if (state.reviews.isEmpty)
          const EmptyState(
            icon: Icons.reviews_outlined,
            title: 'No reviews yet',
            message:
                'Reviews appear here once customers who ordered this item '
                'rate their arrived order.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 780;
              final summary = _ReviewSummary(state: state);
              final list = _ReviewList(reviews: state.reviews);

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 18), list],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 260, child: summary),
                  const SizedBox(width: 24),
                  Expanded(child: list),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.state});

  final ItemDetailsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.stats.average.toStringAsFixed(1),
            style: context.texts.displayLarge,
          ),
          const SizedBox(height: 4),
          RatingStars(
            value: state.stats.average,
            count: state.stats.count,
            starSize: 20,
          ),
          const SizedBox(height: 14),
          for (final row in state.ratingBreakdown)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${row.stars}★',
                      style: context.texts.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: row.fraction,
                        minHeight: 7,
                        backgroundColor: palette.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation(palette.accent),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${row.count}',
                      textAlign: TextAlign.right,
                      style: context.texts.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      // review cards fill the column width
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final review in reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: review.authorName,
                              style: context.texts.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.palette.ink,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' · ${Formatters.shortDate(review.createdAt)}',
                              style: context.texts.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      RatingStars(
                        value: review.rating.toDouble(),
                        showValue: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.comment.isEmpty
                        ? 'Rated without a written comment.'
                        : review.comment,
                    style: context.texts.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RelatedGrid extends StatelessWidget {
  const _RelatedGrid({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 22,
        mainAxisSpacing: 22,
        mainAxisExtent: 400,
      ),
      itemBuilder: (context, index) =>
          ItemCard(item: items[index], stats: const ReviewStats.empty()),
    );
  }
}
