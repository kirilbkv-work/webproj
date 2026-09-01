import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// local storage wrapper; repositories persist their state here
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
      // stale schema, fall back to the seed data
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

  /// wipes the prototype state
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
