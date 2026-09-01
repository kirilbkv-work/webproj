import 'package:equatable/equatable.dart';

/// Одноразовое сообщение пользователю (уведомление о резервировании,
/// подтверждение сохранения, сообщение об ошибке).
///
/// Хранится в состоянии BLoC вместе с уникальным [id], чтобы `BlocListener`
/// показывал даже два одинаковых сообщения подряд.
class AppMessage extends Equatable {
  const AppMessage({
    required this.id,
    required this.title,
    required this.body,
    this.isError = false,
    this.actionLabel,
    this.actionRoute,
  });

  final int id;
  final String title;
  final String body;
  final bool isError;

  /// Кнопка перехода внутри уведомления, например «Open cart».
  final String? actionLabel;
  final String? actionRoute;

  @override
  List<Object?> get props => [id, title, body, isError, actionLabel, actionRoute];
}

/// Источник возрастающих идентификаторов сообщений.
class MessageIds {
  MessageIds._();

  static int _next = 0;

  static int next() => ++_next;
}
