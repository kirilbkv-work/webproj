part of 'orders_bloc.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.lines = const [],
    this.totals = const CartTotals.empty(),
    this.filter,
    this.message,
  });

  /// every reserved item of the current customer
  final List<CartLine> lines;

  /// total price and per-status breakdown
  final CartTotals totals;

  /// null means every status
  final OrderStatus? filter;

  /// one-shot snack bar message, including the reservation notice
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
