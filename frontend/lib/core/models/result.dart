import 'package:equatable/equatable.dart';

/// outcome of a repository call
class Result extends Equatable {
  const Result.success() : error = null;

  const Result.failure(String this.error);

  final String? error;

  bool get isSuccess => error == null;

  bool get isFailure => error != null;

  @override
  List<Object?> get props => [error];
}
