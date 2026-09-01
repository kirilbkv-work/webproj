import 'dart:math';

/// Генератор идентификаторов для записей, созданных во время сессии.
abstract final class IdGenerator {
  static final Random _random = Random();
  static int _counter = 0;

  static String create(String prefix) {
    _counter += 1;
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final noise = _random.nextInt(1 << 20).toRadixString(36);
    return '$prefix-$stamp${_counter.toRadixString(36)}$noise';
  }
}
