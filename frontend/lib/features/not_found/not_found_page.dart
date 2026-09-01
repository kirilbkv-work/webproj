import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/ui_kit.dart';

/// shown for unknown routes
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      child: EmptyState(
        icon: Icons.help_outline,
        title: 'This page does not exist',
        message: 'The address you opened is not part of the prototype.',
        action: FilledButton(
          onPressed: () => context.go('/catalog'),
          child: const Text('Go to the catalog'),
        ),
      ),
    );
  }
}
