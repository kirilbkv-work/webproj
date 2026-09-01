import '../../core/models/models.dart';
import '../../core/utils/id_generator.dart';
import '../seed/seed_data.dart';
import '../services/storage_service.dart';
import '../services/value_store.dart';
import 'auth_repository.dart';
import 'catalog_repository.dart';
import 'review_repository.dart';

/// Симуляция backend-логики заказов: резервирование, чтение корзины,
/// изменение, удаление и выставление оценки.
///
/// Правила, заданные заданием (что разрешено в каком статусе), живут здесь,
/// поэтому BLoC остаётся тонким: он только транслирует события в вызовы.
class OrderRepository {
  OrderRepository({
    required StorageService storage,
    required CatalogRepository catalog,
    required ReviewRepository reviews,
    required AuthRepository auth,
  }) : _storage = storage,
       _catalog = catalog,
       _reviews = reviews,
       _auth = auth,
       _store = ValueStore<List<Order>>(
         _sortedByDate(
           storage.readList('orders', Order.fromJson, SeedData.orders),
         ),
       );

  static const String _key = 'orders';

  final StorageService _storage;
  final CatalogRepository _catalog;
  final ReviewRepository _reviews;
  final AuthRepository _auth;
  final ValueStore<List<Order>> _store;

  List<Order> get orders => List.unmodifiable(_store.value);

  Stream<List<Order>> get stream => _store.stream;

  Order? byId(String id) {
    for (final order in _store.value) {
      if (order.id == id) return order;
    }
    return null;
  }

  /// Заказы текущего пользователя, свежие сверху.
  List<Order> get myOrders {
    final user = _auth.currentUser;
    if (user == null) return const [];
    return _store.value.where((order) => order.userId == user.id).toList();
  }

  List<Order> myOrdersForItem(String itemId) =>
      myOrders.where((order) => order.itemId == itemId).toList();

  /// Содержимое Order Cart с раскрытыми данными товаров.
  List<CartLine> get cart {
    final lines = <CartLine>[];
    for (final order in myOrders) {
      final item = _catalog.byId(order.itemId);
      if (item != null) lines.add(CartLine(order: order, item: item));
    }
    return lines;
  }

  /// Резервирование товара. Товар попадает в Order Cart со статусом
  /// «in progress», покупатель получает уведомление на стороне UI.
  Result reserve(String itemId, OrderDraft draft) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Result.failure('Please sign in to reserve items.');
    }
    if (_catalog.byId(itemId) == null) {
      return const Result.failure('This item is no longer available.');
    }
    final invalid = draft.validate();
    if (invalid != null) return Result.failure(invalid);

    final order = Order(
      id: IdGenerator.create('ord'),
      userId: user.id,
      itemId: itemId,
      size: draft.size,
      quantity: draft.quantity,
      status: OrderStatus.inProgress,
      reservedAt: DateTime.now(),
      deliveryAddress: draft.deliveryAddress.trim(),
      note: draft.note.trim(),
    );
    _commit([order, ..._store.value]);
    return const Result.success();
  }

  /// Изменение данных заказа — только в статусах «in progress» и «canceled».
  Result update(String orderId, OrderDraft draft) {
    final order = byId(orderId);
    if (order == null) return const Result.failure('Order not found.');
    if (!order.status.canEdit) {
      return const Result.failure(
        'Only orders that are in progress or canceled can be edited.',
      );
    }
    final invalid = draft.validate();
    if (invalid != null) return Result.failure(invalid);

    _commit([
      for (final candidate in _store.value)
        if (candidate.id == orderId)
          candidate.copyWith(
            size: draft.size,
            quantity: draft.quantity,
            deliveryAddress: draft.deliveryAddress.trim(),
            note: draft.note.trim(),
          )
        else
          candidate,
    ]);
    return const Result.success();
  }

  /// Удаление заказа из корзины — только в статусе «arrived».
  Result remove(String orderId) {
    final order = byId(orderId);
    if (order == null) return const Result.failure('Order not found.');
    if (!order.status.canDelete) {
      return const Result.failure(
        'Only arrived orders can be removed from the cart.',
      );
    }
    _commit(_store.value.where((candidate) => candidate.id != orderId).toList());
    return const Result.success();
  }

  /// Оценка заказа. Разрешена только для собственных заказов в статусе
  /// «arrived»; оценка публикуется как отзыв о товаре.
  Result rate(String orderId, int rating, String comment) {
    final user = _auth.currentUser;
    final order = byId(orderId);
    if (user == null || order == null || order.userId != user.id) {
      return const Result.failure('You can only rate your own orders.');
    }
    if (!order.status.canRate) {
      return const Result.failure('Only arrived orders can be rated.');
    }
    if (rating < 1 || rating > 5) {
      return const Result.failure(
        'Please choose a rating between 1 and 5 stars.',
      );
    }

    final trimmed = comment.trim();
    var reviewId = order.reviewId;
    if (reviewId != null && _reviews.byId(reviewId) != null) {
      _reviews.update(reviewId, rating: rating, comment: trimmed);
    } else {
      reviewId = _reviews
          .add(
            itemId: order.itemId,
            authorId: user.id,
            authorName: user.fullName,
            rating: rating,
            comment: trimmed,
            orderId: order.id,
          )
          .id;
    }

    _commit([
      for (final candidate in _store.value)
        if (candidate.id == orderId)
          candidate.copyWith(rating: rating, reviewId: reviewId)
        else
          candidate,
    ]);
    return const Result.success();
  }

  /// Демонстрационный переход статуса: позволяет показать сценарий
  /// «заказ приехал» без реального backend.
  Result changeStatus(String orderId, OrderStatus status) {
    if (byId(orderId) == null) return const Result.failure('Order not found.');
    _commit([
      for (final candidate in _store.value)
        if (candidate.id == orderId) candidate.copyWith(status: status) else candidate,
    ]);
    return const Result.success();
  }

  void reset() => _commit(SeedData.orders);

  void _commit(List<Order> next) {
    final sorted = _sortedByDate(next);
    _storage.writeList(_key, sorted, (order) => order.toJson());
    _store.emit(sorted);
  }

  static List<Order> _sortedByDate(List<Order> orders) => List<Order>.of(orders)
    ..sort((a, b) => b.reservedAt.compareTo(a.reservedAt));

  Future<void> dispose() => _store.dispose();
}
