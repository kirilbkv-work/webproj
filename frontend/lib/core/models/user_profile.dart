import 'package:equatable/equatable.dart';

import 'clothing.dart';

/// Профиль покупателя — единственный тип пользователя в приложении.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.favoriteTypes,
    required this.username,
    required this.password,
    required this.memberSince,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final List<ClothingType> favoriteTypes;
  final String username;

  /// Только для прототипа: пароль хранится в открытом виде.
  final String password;
  final DateTime memberSince;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    return '$first$last'.toUpperCase();
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    List<ClothingType>? favoriteTypes,
    String? username,
    String? password,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      favoriteTypes: favoriteTypes ?? this.favoriteTypes,
      username: username ?? this.username,
      password: password ?? this.password,
      memberSince: memberSince,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'favoriteTypes': favoriteTypes.map((type) => type.wireName).toList(),
    'username': username,
    'password': password,
    'memberSince': memberSince.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    favoriteTypes: (json['favoriteTypes'] as List<dynamic>)
        .map((value) => ClothingType.fromWire(value as String))
        .toList(),
    username: json['username'] as String,
    password: json['password'] as String,
    memberSince: DateTime.parse(json['memberSince'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    address,
    favoriteTypes,
    username,
    password,
    memberSince,
  ];
}

/// Данные, которые пользователь заполняет при регистрации.
class RegistrationData extends Equatable {
  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.favoriteTypes,
    required this.username,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final List<ClothingType> favoriteTypes;
  final String username;
  final String password;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    address,
    favoriteTypes,
    username,
    password,
  ];
}

/// Редактируемая часть профиля (без пароля).
class ProfileDraft extends Equatable {
  const ProfileDraft({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.favoriteTypes,
    required this.username,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final List<ClothingType> favoriteTypes;
  final String username;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    address,
    favoriteTypes,
    username,
  ];
}
