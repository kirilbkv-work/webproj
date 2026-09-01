import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../core/utils/id_generator.dart';
import '../seed/seed_data.dart';
import '../services/storage_service.dart';
import '../services/value_store.dart';

/// registered customers plus the current session
class AuthData extends Equatable {
  const AuthData({required this.users, required this.currentUserId});

  final List<UserProfile> users;
  final String? currentUserId;

  UserProfile? get currentUser {
    final id = currentUserId;
    if (id == null) return null;
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  bool get isAuthenticated => currentUser != null;

  AuthData copyWith({List<UserProfile>? users, String? currentUserId, bool clearSession = false}) {
    return AuthData(
      users: users ?? this.users,
      currentUserId: clearSession ? null : (currentUserId ?? this.currentUserId),
    );
  }

  @override
  List<Object?> get props => [users, currentUserId];
}

/// simulated authentication
class AuthRepository {
  AuthRepository(this._storage)
    : _store = ValueStore<AuthData>(
        AuthData(
          users: _storage.readList('users', UserProfile.fromJson, SeedData.users),
          currentUserId: _storage.readString('session'),
        ),
      );

  static const String _usersKey = 'users';
  static const String _sessionKey = 'session';

  final StorageService _storage;
  final ValueStore<AuthData> _store;

  AuthData get data => _store.value;

  Stream<AuthData> get stream => _store.stream;

  UserProfile? get currentUser => _store.value.currentUser;

  bool get isAuthenticated => _store.value.isAuthenticated;

  Result login(String username, String password) {
    final normalized = username.trim().toLowerCase();
    UserProfile? found;
    for (final user in _store.value.users) {
      if (user.username.toLowerCase() == normalized) {
        found = user;
        break;
      }
    }
    if (found == null) {
      return const Result.failure('No account found with that username.');
    }
    if (found.password != password) {
      return const Result.failure('Incorrect password. Please try again.');
    }
    _commitSession(found.id);
    return const Result.success();
  }

  Result register(RegistrationData data) {
    if (isUsernameTaken(data.username)) {
      return const Result.failure('That username is already registered.');
    }
    if (isEmailTaken(data.email)) {
      return const Result.failure('That email address is already registered.');
    }
    final user = UserProfile(
      id: IdGenerator.create('usr'),
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phone: data.phone,
      address: data.address,
      favoriteTypes: data.favoriteTypes,
      username: data.username,
      password: data.password,
      memberSince: DateTime.now(),
    );
    _commitUsers([..._store.value.users, user], sessionId: user.id);
    return const Result.success();
  }

  void logout() => _commitSession(null);

  Result updateProfile(ProfileDraft draft) {
    final current = currentUser;
    if (current == null) {
      return const Result.failure('You are not signed in.');
    }
    if (isUsernameTaken(draft.username, exceptId: current.id)) {
      return const Result.failure('That username is already registered.');
    }
    if (isEmailTaken(draft.email, exceptId: current.id)) {
      return const Result.failure('That email address is already registered.');
    }
    _commitUsers([
      for (final user in _store.value.users)
        if (user.id == current.id)
          user.copyWith(
            firstName: draft.firstName,
            lastName: draft.lastName,
            email: draft.email,
            phone: draft.phone,
            address: draft.address,
            favoriteTypes: draft.favoriteTypes,
            username: draft.username,
          )
        else
          user,
    ]);
    return const Result.success();
  }

  Result changePassword(String currentPassword, String nextPassword) {
    final current = currentUser;
    if (current == null) {
      return const Result.failure('You are not signed in.');
    }
    if (current.password != currentPassword) {
      return const Result.failure('Current password is incorrect.');
    }
    _commitUsers([
      for (final user in _store.value.users)
        if (user.id == current.id) user.copyWith(password: nextPassword) else user,
    ]);
    return const Result.success();
  }

  bool isUsernameTaken(String username, {String? exceptId}) {
    final normalized = username.trim().toLowerCase();
    return _store.value.users.any(
      (user) => user.id != exceptId && user.username.toLowerCase() == normalized,
    );
  }

  bool isEmailTaken(String email, {String? exceptId}) {
    final normalized = email.trim().toLowerCase();
    return _store.value.users.any(
      (user) => user.id != exceptId && user.email.toLowerCase() == normalized,
    );
  }

  void reset() {
    _storage.writeList(_usersKey, SeedData.users, (user) => user.toJson());
    _storage.writeString(_sessionKey, null);
    _store.emit(AuthData(users: SeedData.users, currentUserId: null));
  }

  void _commitUsers(List<UserProfile> users, {String? sessionId}) {
    _storage.writeList(_usersKey, users, (user) => user.toJson());
    final session = sessionId ?? _store.value.currentUserId;
    if (sessionId != null) {
      _storage.writeString(_sessionKey, sessionId);
    }
    _store.emit(AuthData(users: users, currentUserId: session));
  }

  void _commitSession(String? userId) {
    _storage.writeString(_sessionKey, userId);
    _store.emit(
      AuthData(users: _store.value.users, currentUserId: userId),
    );
  }

  Future<void> dispose() => _store.dispose();
}
