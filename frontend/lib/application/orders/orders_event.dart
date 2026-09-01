part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => const [];
}

/// Фильтр корзины по статусу заказа. `null` — показать все заказы.
class OrdersFilterChanged extends OrdersEvent {
  const OrdersFilterChanged(this.status);

  final OrderStatus? status;

  @override
  List<Object?> get props => [status];
}

/// Резервирование товара из карточки товара.
class OrderReserved extends OrdersEvent {
  const OrderReserved({required this.itemId, required this.draft});

  final String itemId;
  final OrderDraft draft;

  @override
  List<Object?> get props => [itemId, draft];
}

/// Изменение данных заказа — статусы «in progress» и «canceled».
class OrderEdited extends OrdersEvent {
  const OrderEdited({required this.orderId, required this.draft});

  final String orderId;
  final OrderDraft draft;

  @override
  List<Object?> get props => [orderId, draft];
}

/// Удаление заказа из корзины — только статус «arrived».
class OrderDeleted extends OrdersEvent {
  const OrderDeleted(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

/// Выставление оценки — только собственный заказ в статусе «arrived».
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

/// Демонстрационная смена статуса заказа.
class OrderStatusSimulated extends OrdersEvent {
  const OrderStatusSimulated({required this.orderId, required this.status});

  final String orderId;
  final OrderStatus status;

  @override
  List<Object?> get props => [orderId, status];
}

/// Внутреннее событие: изменились заказы, каталог или сессия.
class _OrdersDataChanged extends OrdersEvent {
  const _OrdersDataChanged();
}
