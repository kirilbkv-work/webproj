import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/orders/orders_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/review_repository.dart';
import '../shared/widgets/item_cover.dart';
import '../shared/widgets/rating_stars.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/widgets/ui_kit.dart';
import 'widgets/edit_order_dialog.dart';
import 'widgets/rate_order_dialog.dart';

/// order cart; available actions depend on the order status
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 24),
              if (state.isEmpty)
                EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your Order Cart is empty',
                  message:
                      'Reserve an item from the catalog and it will appear '
                      'here with its status and price.',
                  action: FilledButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('Browse the catalog'),
                  ),
                )
              else ...[
                _Summary(state: state),
                const SizedBox(height: 20),
                _Filters(state: state),
                const SizedBox(height: 20),
                if (state.visibleLines.isEmpty)
                  const EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No orders with this status',
                    message:
                        'Switch to another status to see the rest of your '
                        'orders.',
                  )
                else
                  for (final line in state.visibleLines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OrderRow(line: line),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Your reservations'),
              const SizedBox(height: 6),
              Text('Order Cart', style: context.texts.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Every item you reserve is collected here with its full '
                'details and current status. The total price is recalculated '
                'automatically.',
                style: context.texts.bodyLarge,
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => context.go('/catalog'),
          child: const Text('Continue browsing'),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final totals = state.totals;

    final total = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Eyebrow('Total price'),
        const SizedBox(height: 4),
        Text(Formatters.money(totals.total), style: context.texts.displayLarge),
        const SizedBox(height: 2),
        Text(
          '${Formatters.plural(state.lines.length, 'order', 'orders')} · '
          '${Formatters.plural(totals.itemCount, 'piece', 'pieces')}',
          style: context.texts.bodySmall,
        ),
      ],
    );

    final breakdown = Column(
      children: [
        for (final status in OrderStatus.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.label,
                      style: context.texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.plural(
                      totals.forStatus(status).count,
                      'order',
                      'orders',
                    ),
                    style: context.texts.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 92,
                    child: Text(
                      Formatters.money(totals.forStatus(status).total),
                      textAlign: TextAlign.right,
                      style: context.texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [total, const SizedBox(height: 18), breakdown],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 230, child: total),
              const SizedBox(width: 32),
              Expanded(child: breakdown),
            ],
          );
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OrdersBloc>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SelectableChip(
          label: 'All orders (${state.lines.length})',
          selected: state.filter == null,
          onTap: () => bloc.add(const OrdersFilterChanged(null)),
        ),
        for (final status in OrderStatus.values)
          SelectableChip(
            label: '${status.label} (${state.totals.forStatus(status).count})',
            selected: state.filter == status,
            onTap: () => bloc.add(OrdersFilterChanged(status)),
          ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.line});

  final CartLine line;

  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    final draft = await EditOrderDialog.show(context, line);
    if (draft == null) return;
    bloc.add(OrderEdited(orderId: line.order.id, draft: draft));
  }

  Future<void> _rate(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    final reviewId = line.order.reviewId;
    final existing = reviewId == null
        ? null
        : context.read<ReviewRepository>().byId(reviewId);
    final result = await RateOrderDialog.show(
      context,
      line: line,
      initialComment: existing?.comment ?? '',
    );
    if (result == null) return;
    bloc.add(
      OrderRated(
        orderId: line.order.id,
        rating: result.rating,
        comment: result.comment,
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final bloc = context.read<OrdersBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete this order?',
          style: dialogContext.texts.headlineSmall,
        ),
        content: SizedBox(
          width: 420,
          child: Text(
            '${line.item.name} (size ${line.order.size.label}) will be '
            'removed from your Order Cart. Reviews you already published '
            'stay on the item page.',
            style: dialogContext.texts.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.palette.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete order'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      bloc.add(OrderDeleted(line.order.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final order = line.order;
    final item = line.item;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.go('/catalog/${item.id}'),
                    child: Text(
                      item.name,
                      style: context.texts.headlineSmall?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    '${item.type.label} · ${item.manufacturer}',
                    style: context.texts.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(status: order.status),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: palette.line, height: 1),
        const SizedBox(height: 12),
        SpecGrid(
          minColumnWidth: 110,
          entries: [
            SpecEntry('Size', order.size.label),
            SpecEntry('Quantity', '${order.quantity}'),
            SpecEntry('Unit price', Formatters.money(item.price)),
            SpecEntry('Product date', Formatters.shortDate(item.productDate)),
            SpecEntry('Reserved on', Formatters.shortDate(order.reservedAt)),
            SpecEntry('Line total', Formatters.money(line.lineTotal)),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: palette.line, height: 1),
        const SizedBox(height: 12),
        Text(
          'Delivering to ${order.deliveryAddress}'
          '${order.note.isEmpty ? '' : ' · “${order.note}”'}',
          style: context.texts.bodySmall,
        ),
        const SizedBox(height: 10),
        _RatingRow(order: order),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (order.status.canEdit)
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                onPressed: () => _edit(context),
                child: const Text('Edit order details'),
              ),
            if (order.status.canRate)
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
                onPressed: () => _rate(context),
                child: Text(
                  order.rating != null ? 'Update rating' : 'Rate this order',
                ),
              ),
            if (order.status.canDelete)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  foregroundColor: palette.danger,
                  backgroundColor: palette.dangerTint,
                  side: BorderSide(color: palette.dangerTint),
                ),
                onPressed: () => _delete(context),
                child: const Text('Delete order'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SimulationControls(order: order),
      ],
    );

    return Panel(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: ItemCover(item: item),
                ),
                const SizedBox(height: 16),
                details,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 168, child: ItemCover(item: item)),
              const SizedBox(width: 20),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    // the assignment shows ratings for arrived orders only
    if (!order.status.canRate) {
      return Text(
        'Rating becomes available once the order arrives',
        style: context.texts.bodySmall,
      );
    }
    if (order.rating == null) {
      return Text('Not rated yet', style: context.texts.bodySmall);
    }
    return Wrap(
      spacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Your rating', style: context.texts.bodySmall),
        RatingStars(value: order.rating!.toDouble(), showValue: false),
        Text(
          '${order.rating} / 5',
          style: context.texts.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.palette.accent,
          ),
        ),
      ],
    );
  }
}

/// prototype-only status change
class _SimulationControls extends StatelessWidget {
  const _SimulationControls({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bloc = context.read<OrdersBloc>();

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Prototype control — simulate status change:',
            style: context.texts.bodySmall,
          ),
          for (final status in OrderStatus.values)
            if (status != order.status)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: palette.inkSoft,
                ),
                onPressed: () => bloc.add(
                  OrderStatusSimulated(orderId: order.id, status: status),
                ),
                child: Text('→ ${status.label}'),
              ),
        ],
      ),
    );
  }
}
