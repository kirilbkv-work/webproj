import '../services/storage_service.dart';
import 'auth_repository.dart';
import 'catalog_repository.dart';
import 'order_repository.dart';
import 'review_repository.dart';

/// Возврат прототипа к предопределённому набору данных.
class DemoDataService {
  DemoDataService({
    required StorageService storage,
    required CatalogRepository catalog,
    required ReviewRepository reviews,
    required OrderRepository orders,
    required AuthRepository auth,
  }) : _storage = storage,
       _catalog = catalog,
       _reviews = reviews,
       _orders = orders,
       _auth = auth;

  final StorageService _storage;
  final CatalogRepository _catalog;
  final ReviewRepository _reviews;
  final OrderRepository _orders;
  final AuthRepository _auth;

  Future<void> resetAll() async {
    await _storage.clearAll();
    _catalog.reset();
    _reviews.reset();
    _orders.reset();
    _auth.reset();
  }
}
