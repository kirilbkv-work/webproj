part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.data);

  final RegistrationData data;

  @override
  List<Object?> get props => [data];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileSubmitted extends AuthEvent {
  const AuthProfileSubmitted(this.draft);

  final ProfileDraft draft;

  @override
  List<Object?> get props => [draft];
}

class AuthPasswordSubmitted extends AuthEvent {
  const AuthPasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// clears the inline form error
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

/// internal: repository data changed
class _AuthDataChanged extends AuthEvent {
  const _AuthDataChanged(this.data);

  final AuthData data;

  @override
  List<Object?> get props => [data];
}
