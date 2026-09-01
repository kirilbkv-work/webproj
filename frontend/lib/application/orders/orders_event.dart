part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => const [];
}

/// null shows every order
class OrdersFilterChanged extends OrdersEvent {
  const OrdersFilterChanged(this.status);

  final OrderStatus? status;

  @override
  List<Object?> get props => [status];
}

/// reserve an item
class OrderReserved extends OrdersEvent {
  const OrderReserved({required this.itemId, required this.draft});

  final String itemId;
  final OrderDraft draft;

  @override
  List<Object?> get props => [itemId, draft];
}

/// allowed for in progress and canceled orders
class OrderEdited extends OrdersEvent {
  const OrderEdited({required this.orderId, required this.draft});

  final String orderId;
  final OrderDraft draft;

  @override
  List<Object?> get props => [orderId, draft];
}

/// allowed for arrived orders only
class OrderDeleted extends OrdersEvent {
  const OrderDeleted(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

/// own arrived orders only
class OrderRated extends OrdersEvent {
  const OrderRated({
    required this.orderId,
    required this.rating,
    required this.comment,
  });

  final String orderId;
  final int rating;
  final String comment;

  @override
  List<Object?> get props => [orderId, rating, comment];
}

/// prototype-only status change
class OrderStatusSimulated extends OrdersEvent {
  const OrderStatusSimulated({required this.orderId, required this.status});

  final String orderId;
  final OrderStatus status;

  @override
  List<Object?> get props => [orderId, status];
}

/// internal: orders, catalog or session changed
class _OrdersDataChanged extends OrdersEvent {
  const _OrdersDataChanged();
}
