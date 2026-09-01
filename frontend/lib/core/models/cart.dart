import 'package:equatable/equatable.dart';

import 'item.dart';
import 'order.dart';

/// Строка корзины: заказ вместе с данными товара.
class CartLine extends Equatable {
  const CartLine({required this.order, required this.item});

  final Order order;
  final Item item;

  double get lineTotal => item.price * order.quantity;

  @override
  List<Object?> get props => [order, item];
}

/// Итоги по одному статусу заказа.
class StatusTotals extends Equatable {
  const StatusTotals({required this.count, required this.total});

  const StatusTotals.empty() : count = 0, total = 0;

  final int count;
  final double total;

  @override
  List<Object?> get props => [count, total];
}

/// Общая стоимость корзины. Пересчитывается автоматически при любом
/// изменении состава заказов.
class CartTotals extends Equatable {
  const CartTotals({
    required this.total,
    required this.itemCount,
    required this.byStatus,
  });

  const CartTotals.empty()
    : total = 0,
      itemCount = 0,
      byStatus = const <OrderStatus, StatusTotals>{};

  final double total;
  final int itemCount;
  final Map<OrderStatus, StatusTotals> byStatus;

  StatusTotals forStatus(OrderStatus status) =>
      byStatus[status] ?? const StatusTotals.empty();

  /// Считает итоги по списку строк корзины.
  factory CartTotals.from(List<CartLine> lines) {
    var total = 0.0;
    var itemCount = 0;
    final counts = <OrderStatus, int>{};
    final sums = <OrderStatus, double>{};

    for (final line in lines) {
      total += line.lineTotal;
      itemCount += line.order.quantity;
      counts[line.order.status] = (counts[line.order.status] ?? 0) + 1;
      sums[line.order.status] =
          (sums[line.order.status] ?? 0) + line.lineTotal;
    }

    return CartTotals(
      total: total,
      itemCount: itemCount,
      byStatus: {
        for (final status in OrderStatus.values)
          status: StatusTotals(
            count: counts[status] ?? 0,
            total: sums[status] ?? 0,
          ),
      },
    );
  }

  @override
  List<Object?> get props => [total, itemCount, byStatus];
}
