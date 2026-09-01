import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// sign in, register, sign out and profile edits
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(AuthState(data: repository.data)) {
    on<_AuthDataChanged>(_onDataChanged);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthProfileSubmitted>(_onProfileSubmitted);
    on<AuthPasswordSubmitted>(_onPasswordSubmitted);
    on<AuthErrorCleared>(_onErrorCleared);

    _subscription = _repository.stream.listen(
      (data) => add(_AuthDataChanged(data)),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthData> _subscription;

  void _onDataChanged(_AuthDataChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(data: event.data));
  }

  void _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) {
    final result = _repository.login(event.username, event.password);
    if (result.isFailure) {
      emit(state.copyWith(formError: result.error));
      return;
    }
    emit(
      state.copyWith(
        clearFormError: true,
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Welcome back',
          body: 'You are signed in to your account.',
        ),
      ),
    );
  }

  void _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) {
    final result = _repository.register(event.data);
    if (result.isFailure) {
      emit(state.copyWith(formError: result.error));
      return;
    }
    emit(
      state.copyWith(
        clearFormError: true,
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Account created',
          body: 'Your profile is ready — you can now reserve items.',
        ),
      ),
    );
  }

  void _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) {
    _repository.logout();
    emit(
      state.copyWith(
        clearFormError: true,
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Signed out',
          body: 'You can keep browsing the catalog as a guest.',
        ),
      ),
    );
  }

  void _onProfileSubmitted(
    AuthProfileSubmitted event,
    Emitter<AuthState> emit,
  ) {
    final result = _repository.updateProfile(event.draft);
    if (result.isFailure) {
      emit(state.copyWith(formError: result.error));
      return;
    }
    emit(
      state.copyWith(
        clearFormError: true,
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Profile updated',
          body: 'Your profile data was saved.',
        ),
      ),
    );
  }

  void _onPasswordSubmitted(
    AuthPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) {
    final result = _repository.changePassword(
      event.currentPassword,
      event.newPassword,
    );
    if (result.isFailure) {
      emit(state.copyWith(formError: result.error));
      return;
    }
    emit(
      state.copyWith(
        clearFormError: true,
        message: AppMessage(
          id: MessageIds.next(),
          title: 'Password changed',
          body: 'Use the new password next time you sign in.',
        ),
      ),
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearFormError: true));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
