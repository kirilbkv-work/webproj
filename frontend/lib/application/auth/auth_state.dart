part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({required this.data, this.formError, this.message});

  final AuthData data;

  /// shown inline in the form
  final String? formError;

  /// one-shot snack bar message
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
