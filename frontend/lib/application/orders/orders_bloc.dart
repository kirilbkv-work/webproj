import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/order_repository.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// Order Cart и управление заказами.
///
/// Слушает заказы, каталог и сессию: состав корзины зависит от всех трёх.
/// Правила по статусам проверяет [OrderRepository], поэтому BLoC только
/// транслирует события и превращает результат в сообщение пользователю.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required OrderRepository orders,
    required CatalogRepository catalog,
    required AuthRepository auth,
  }) : _orders = orders,
       _catalog = catalog,
       _auth = auth,
       super(_build(orders, const OrdersState())) {
    on<_OrdersDataChanged>(_onDataChanged);
    on<OrdersFilterChanged>(_onFilterChanged);
    on<OrderReserved>(_onReserved);
    on<OrderEdited>(_onEdited);
    on<OrderDeleted>(_onDeleted);
    on<OrderRated>(_onRated);
    on<OrderStatusSimulated>(_onStatusSimulated);

    _ordersSubscription = _orders.stream.listen(
      (_) => add(const _OrdersDataChanged()),
    );
    _catalogSubscription = _catalog.stream.listen(
      (_) => add(const _OrdersDataChanged()),
    );
    _authSubscription = _auth.stream.listen(
      (_) => add(const _OrdersDataChanged()),
    );
  }

  final OrderRepository _orders;
  final CatalogRepository _catalog;
  final AuthRepository _auth;
  late final StreamSubscription<List<Order>> _ordersSubscription;
  late final StreamSubscription<List<Item>> _catalogSubscription;
  late final StreamSubscription<AuthData> _authSubscription;

  void _onDataChanged(_OrdersDataChanged event, Emitter<OrdersState> emit) {
    emit(_build(_orders, state));
  }

  void _onFilterChanged(OrdersFilterChanged event, Emitter<OrdersState> emit) {
    emit(
      event.status == null
          ? state.copyWith(clearFilter: true)
          : state.copyWith(filter: event.status),
    );
  }

  void _onReserved(OrderReserved event, Emitter<OrdersState> emit) {
    final result = _orders.reserve(event.itemId, event.draft);
    if (result.isFailure) {
      emit(state.copyWith(message: _error('Reservation failed', result.error!)));
      return;
    }
    final item = _catalog.byId(event.itemId);
    emit(
      _build(_orders, state).copyWith(
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Item reserved',
          body:
              '${item?.name ?? 'The item'} (size ${event.draft.size.label}) '
              'was added to your Order Cart.',
          actionLabel: 'Open cart',
          actionRoute: '/cart',
        ),
      ),
    );
  }

  void _onEdited(OrderEdited event, Emitter<OrdersState> emit) {
    final result = _orders.update(event.orderId, event.draft);
    if (result.isFailure) {
      emit(state.copyWith(message: _error('Update failed', result.error!)));
      return;
    }
    emit(
      _build(_orders, state).copyWith(
        message: _info('Order updated', 'The order details were saved.'),
      ),
    );
  }

  void _onDeleted(OrderDeleted event, Emitter<OrdersState> emit) {
    final result = _orders.remove(event.orderId);
    if (result.isFailure) {
      emit(state.copyWith(message: _error('Delete failed', result.error!)));
      return;
    }
    emit(
      _build(_orders, state).copyWith(
        message: _info('Order removed', 'The order was removed from your cart.'),
      ),
    );
  }

  void _onRated(OrderRated event, Emitter<OrdersState> emit) {
    final result = _orders.rate(event.orderId, event.rating, event.comment);
    if (result.isFailure) {
      emit(state.copyWith(message: _error('Rating failed', result.error!)));
      return;
    }
    emit(
      _build(_orders, state).copyWith(
        message: _info(
          'Rating saved',
          'Your review is now visible on the item page.',
        ),
      ),
    );
  }

  void _onStatusSimulated(
    OrderStatusSimulated event,
    Emitter<OrdersState> emit,
  ) {
    final result = _orders.changeStatus(event.orderId, event.status);
    if (result.isFailure) {
      emit(state.copyWith(message: _error('Status change failed', result.error!)));
      return;
    }
    emit(
      _build(_orders, state).copyWith(
        message: _info(
          'Status changed',
          'The order is now marked as "${event.status.wireName}".',
        ),
      ),
    );
  }

  static OrdersState _build(OrderRepository orders, OrdersState base) {
    final lines = orders.cart;
    return base.copyWith(lines: lines, totals: CartTotals.from(lines));
  }

  static AppMessage _info(String title, String body) =>
      AppMessage(id: MessageIds.next(), title: title, body: body);

  static AppMessage _error(String title, String body) =>
      AppMessage(id: MessageIds.next(), title: title, body: body, isError: true);

  @override
  Future<void> close() {
    _ordersSubscription.cancel();
    _catalogSubscription.cancel();
    _authSubscription.cancel();
    return super.close();
  }
}
