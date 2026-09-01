import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../application/item_details/item_details_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/review_repository.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/cart/cart_page.dart';
import '../features/catalog/catalog_page.dart';
import '../features/item/item_details_page.dart';
import '../features/not_found/not_found_page.dart';
import '../features/profile/profile_page.dart';
import '../features/reviews/reviews_page.dart';
import '../features/shared/app_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// routes that require an account
const Set<String> _protectedRoutes = {'/cart', '/profile'};

/// routes hidden from signed-in customers
const Set<String> _guestOnlyRoutes = {'/login', '/register'};

/// builds the router; access checks live in redirect
GoRouter createRouter({
  required AuthRepository auth,
  required CatalogRepository catalog,
  required ReviewRepository reviews,
  required OrderRepository orders,
}) {
  return GoRouter(
    initialLocation: '/catalog',
    refreshListenable: _AuthRefreshNotifier(auth.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authenticated = auth.isAuthenticated;

      if (!authenticated && _protectedRoutes.contains(location)) {
        final target = Uri.encodeComponent(state.uri.toString());
        return '/login?returnUrl=$target';
      }
      if (authenticated && _guestOnlyRoutes.contains(location)) {
        return '/catalog';
      }
      return null;
    },
    errorBuilder: (context, state) => const AppShell(child: NotFoundPage()),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', redirect: (_, _) => '/catalog'),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogPage(),
          ),
          GoRoute(
            path: '/catalog/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              // per-page bloc, scoped to this item
              return BlocProvider(
                key: ValueKey(id),
                create: (_) => ItemDetailsBloc(
                  itemId: id,
                  catalog: catalog,
                  reviews: reviews,
                  orders: orders,
                  auth: auth,
                ),
                child: const ItemDetailsPage(),
              );
            },
          ),
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewsPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                LoginPage(returnUrl: state.uri.queryParameters['returnUrl']),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

/// re-runs redirect when the session changes
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<AuthData> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthData> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
