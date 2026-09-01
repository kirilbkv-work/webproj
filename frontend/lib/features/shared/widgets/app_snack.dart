import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';

/// Показывает одноразовое сообщение BLoC как SnackBar.
///
/// Через этот механизм покупатель получает уведомление о резервировании,
/// которого требует задание.
void showAppMessage(BuildContext context, AppMessage message) {
  final palette = context.palette;
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: message.isError ? palette.danger : palette.ink,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.body,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.86)),
            ),
          ],
        ),
        action: message.actionLabel != null && message.actionRoute != null
            ? SnackBarAction(
                label: message.actionLabel!,
                textColor: Colors.white,
                onPressed: () => context.go(message.actionRoute!),
              )
            : null,
      ),
    );
}
