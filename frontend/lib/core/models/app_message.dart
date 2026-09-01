import 'package:equatable/equatable.dart';

/// one-shot user message; the id makes repeated texts distinct
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

  /// optional navigation action
  final String? actionLabel;
  final String? actionRoute;

  @override
  List<Object?> get props => [id, title, body, isError, actionLabel, actionRoute];
}

/// increasing message ids
class MessageIds {
  MessageIds._();

  static int _next = 0;

  static int next() => ++_next;
}
