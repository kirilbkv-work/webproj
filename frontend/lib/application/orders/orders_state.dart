part of 'orders_bloc.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.lines = const [],
    this.totals = const CartTotals.empty(),
    this.filter,
    this.message,
  });

  /// Все зарезервированные товары текущего покупателя.
  final List<CartLine> lines;

  /// Общая стоимость и разбивка по статусам.
  final CartTotals totals;

  /// Активный фильтр по статусу, `null` — все заказы.
  final OrderStatus? filter;

  /// Одноразовое сообщение для SnackBar (в том числе уведомление
  /// о резервировании, которого требует задание).
  final AppMessage? message;

  bool get isEmpty => lines.isEmpty;

  List<CartLine> get visibleLines => filter == null
      ? lines
      : lines.where((line) => line.order.status == filter).toList();

  List<CartLine> linesForItem(String itemId) =>
      lines.where((line) => line.item.id == itemId).toList();

  OrdersState copyWith({
    List<CartLine>? lines,
    CartTotals? totals,
    OrderStatus? filter,
    bool clearFilter = false,
    AppMessage? message,
  }) {
    return OrdersState(
      lines: lines ?? this.lines,
      totals: totals ?? this.totals,
      filter: clearFilter ? null : (filter ?? this.filter),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [lines, totals, filter, message];
}
