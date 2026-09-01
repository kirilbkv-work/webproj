import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/review_repository.dart';

part 'item_details_event.dart';
part 'item_details_state.dart';

/// Карточка одного товара: атрибуты, отзывы и собственные заказы покупателя.
///
/// Создаётся на время жизни страницы вместе с идентификатором товара.
class ItemDetailsBloc extends Bloc<ItemDetailsEvent, ItemDetailsState> {
  ItemDetailsBloc({
    required String itemId,
    required CatalogRepository catalog,
    required ReviewRepository reviews,
    required OrderRepository orders,
    required AuthRepository auth,
  }) : _itemId = itemId,
       _catalog = catalog,
       _reviews = reviews,
       _orders = orders,
       super(_build(itemId, catalog, reviews, orders)) {
    on<_ItemDetailsDataChanged>(_onDataChanged);

    _subscriptions = [
      catalog.stream.listen((_) => add(const _ItemDetailsDataChanged())),
      reviews.stream.listen((_) => add(const _ItemDetailsDataChanged())),
      orders.stream.listen((_) => add(const _ItemDetailsDataChanged())),
      auth.stream.listen((_) => add(const _ItemDetailsDataChanged())),
    ];
  }

  final String _itemId;
  final CatalogRepository _catalog;
  final ReviewRepository _reviews;
  final OrderRepository _orders;
  late final List<StreamSubscription<Object?>> _subscriptions;

  void _onDataChanged(
    _ItemDetailsDataChanged event,
    Emitter<ItemDetailsState> emit,
  ) {
    emit(_build(_itemId, _catalog, _reviews, _orders));
  }

  static ItemDetailsState _build(
    String itemId,
    CatalogRepository catalog,
    ReviewRepository reviewRepository,
    OrderRepository orders,
  ) {
    final item = catalog.byId(itemId);
    if (item == null) return const ItemDetailsState();

    final reviews = reviewRepository.forItem(itemId);
    final stats =
        ReviewRepository.statsByItem(reviews)[itemId] ??
        const ReviewStats.empty();

    return ItemDetailsState(
      item: item,
      reviews: reviews,
      stats: stats,
      related: catalog.relatedTo(itemId),
      myOrders: orders.myOrdersForItem(itemId),
    );
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
