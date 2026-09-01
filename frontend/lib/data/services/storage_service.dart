import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Обёртка над `shared_preferences`.
///
/// Реального backend нет, поэтому репозитории сохраняют своё состояние здесь —
/// данные переживают перезапуск приложения во время демонстрации.
class StorageService {
  StorageService(this._prefs);

  static const String _prefix = 'dcs:';

  final SharedPreferences _prefs;

  List<T> readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
    List<T> fallback,
  ) {
    final raw = _prefs.getString(_prefix + key);
    if (raw == null) return fallback;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Данные из прошлой версии схемы — откатываемся на исходный набор.
      return fallback;
    }
  }

  void writeList<T>(
    String key,
    List<T> values,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    final raw = jsonEncode(values.map(toJson).toList());
    unawaited(_prefs.setString(_prefix + key, raw));
  }

  String? readString(String key) => _prefs.getString(_prefix + key);

  void writeString(String key, String? value) {
    if (value == null) {
      unawaited(_prefs.remove(_prefix + key));
    } else {
      unawaited(_prefs.setString(_prefix + key, value));
    }
  }

  /// Полностью очищает состояние прототипа.
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
