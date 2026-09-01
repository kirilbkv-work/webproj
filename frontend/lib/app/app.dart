import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../application/auth/auth_bloc.dart';
import '../application/catalog/catalog_bloc.dart';
import '../application/orders/orders_bloc.dart';
import '../application/reviews/reviews_bloc.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/demo_data_service.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/review_repository.dart';
import 'router.dart';

/// app root: repositories, global blocs and routing
class DigitalClothingStoreApp extends StatefulWidget {
  const DigitalClothingStoreApp({
    super.key,
    required this.catalog,
    required this.reviews,
    required this.orders,
    required this.auth,
    required this.demoData,
  });

  final CatalogRepository catalog;
  final ReviewRepository reviews;
  final OrderRepository orders;
  final AuthRepository auth;
  final DemoDataService demoData;

  @override
  State<DigitalClothingStoreApp> createState() =>
      _DigitalClothingStoreAppState();
}

class _DigitalClothingStoreAppState extends State<DigitalClothingStoreApp> {
  late final GoRouter _router = createRouter(
    auth: widget.auth,
    catalog: widget.catalog,
    reviews: widget.reviews,
    orders: widget.orders,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.catalog),
        RepositoryProvider.value(value: widget.reviews),
        RepositoryProvider.value(value: widget.orders),
        RepositoryProvider.value(value: widget.auth),
        RepositoryProvider.value(value: widget.demoData),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(repository: widget.auth)),
          BlocProvider(
            create: (_) =>
                CatalogBloc(catalog: widget.catalog, reviews: widget.reviews),
          ),
          BlocProvider(
            create: (_) => OrdersBloc(
              orders: widget.orders,
              catalog: widget.catalog,
              auth: widget.auth,
            ),
          ),
          BlocProvider(
            create: (_) =>
                ReviewsBloc(reviews: widget.reviews, catalog: widget.catalog),
          ),
        ],
        child: MaterialApp.router(
          title: 'Digital Clothing Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
