import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/demo_data_service.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // no real backend, mocks
  final preferences = await SharedPreferences.getInstance();
  final storage = StorageService(preferences);

  final catalog = CatalogRepository(storage);
  final reviews = ReviewRepository(storage);
  final auth = AuthRepository(storage);
  final orders = OrderRepository(
    storage: storage,
    catalog: catalog,
    reviews: reviews,
    auth: auth,
  );
  final demoData = DemoDataService(
    storage: storage,
    catalog: catalog,
    reviews: reviews,
    orders: orders,
    auth: auth,
  );

  runApp(
    DigitalClothingStoreApp(
      catalog: catalog,
      reviews: reviews,
      orders: orders,
      auth: auth,
      demoData: demoData,
    ),
  );
}
