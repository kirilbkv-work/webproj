part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({required this.data, this.formError, this.message});

  final AuthData data;

  /// Ошибка, показываемая прямо в форме (неверный пароль, занятый логин).
  final String? formError;

  /// Одноразовое сообщение для SnackBar.
  final AppMessage? message;

  UserProfile? get user => data.currentUser;

  bool get isAuthenticated => data.isAuthenticated;

  AuthState copyWith({
    AuthData? data,
    String? formError,
    bool clearFormError = false,
    AppMessage? message,
  }) {
    return AuthState(
      data: data ?? this.data,
      formError: clearFormError ? null : (formError ?? this.formError),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [data, formError, message];
}
