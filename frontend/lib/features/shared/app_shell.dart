import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/orders/orders_bloc.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/demo_data_service.dart';
import 'widgets/app_snack.dart';

/// Оболочка приложения: шапка с навигацией, область страниц, подвал
/// и единая точка показа уведомлений.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrdersBloc, OrdersState>(
          listenWhen: (previous, current) =>
              current.message != null &&
              current.message?.id != previous.message?.id,
          listener: (context, state) => showAppMessage(context, state.message!),
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current.message != null &&
              current.message?.id != previous.message?.id,
          listener: (context, state) => showAppMessage(context, state.message!),
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            const _Masthead(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [child, const _Colophon()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 760;
                final brand = const _BrandMark();
                final nav = const _Nav();
                final account = const _AccountArea();

                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: brand),
                          account,
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: nav,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    brand,
                    const Spacer(),
                    nav,
                    const SizedBox(width: 14),
                    account,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => context.go('/catalog'),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.brand,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              'DC',
              style: context.texts.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Digital Clothing Store',
                style: context.texts.titleLarge?.copyWith(fontSize: 16),
              ),
              Text(
                'BROWSE · RESERVE · REVIEW',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: palette.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final cartCount = context.select<OrdersBloc, int>(
      (bloc) => bloc.state.lines.length,
    );
    final authenticated = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.isAuthenticated,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavLink(
          label: 'Catalog',
          path: '/catalog',
          active: location.startsWith('/catalog'),
        ),
        _NavLink(
          label: 'Reviews',
          path: '/reviews',
          active: location == '/reviews',
        ),
        _NavLink(
          label: 'Order cart',
          path: '/cart',
          active: location == '/cart',
          badge: authenticated && cartCount > 0 ? cartCount : null,
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.path,
    required this.active,
    this.badge,
  });

  final String label;
  final String path;
  final bool active;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: active ? palette.brandTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.texts.bodyMedium?.copyWith(
                    color: active ? palette.brand : palette.inkSoft,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.brand,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _AccountAction { profile, cart, reset, signOut }

class _AccountArea extends StatelessWidget {
  const _AccountArea();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.user != current.user,
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign in'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => context.go('/register'),
                child: const Text('Register'),
              ),
            ],
          );
        }

        return PopupMenuButton<_AccountAction>(
          tooltip: 'Account menu',
          position: PopupMenuPosition.under,
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(color: palette.line),
          ),
          onSelected: (action) => _handle(context, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: context.texts.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  Text(user.email, style: context.texts.bodySmall),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _AccountAction.profile,
              child: Text('My profile'),
            ),
            const PopupMenuItem(
              value: _AccountAction.cart,
              child: Text('Order cart'),
            ),
            const PopupMenuItem(
              value: _AccountAction.reset,
              child: Text('Restore demo data'),
            ),
            PopupMenuItem(
              value: _AccountAction.signOut,
              child: Text(
                'Sign out',
                style: TextStyle(color: palette.danger),
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.lineStrong),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.brandTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: palette.brand,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.firstName,
                  style: context.texts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Icon(Icons.expand_more, size: 18, color: palette.inkMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handle(BuildContext context, _AccountAction action) async {
    switch (action) {
      case _AccountAction.profile:
        context.go('/profile');
      case _AccountAction.cart:
        context.go('/cart');
      case _AccountAction.reset:
        final demoData = context.read<DemoDataService>();
        final messenger = ScaffoldMessenger.of(context);
        final router = GoRouter.of(context);
        await demoData.resetAll();
        router.go('/catalog');
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Demo data restored — items, orders and reviews were reset.',
              ),
            ),
          );
      case _AccountAction.signOut:
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go('/catalog');
    }
  }
}

class _Colophon extends StatelessWidget {
  const _Colophon();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.bgDeep,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    'Digital Clothing Store — user interface prototype. '
                    'All data is simulated in the app through Dart models, '
                    'repositories and BLoC.',
                    style: context.texts.bodySmall,
                  ),
                ),
                Text(
                  'Web Programming annual project',
                  style: context.texts.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
