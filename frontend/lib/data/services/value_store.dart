import 'dart:async';

/// Наблюдаемое значение: хранит текущее состояние и вещает изменения.
///
/// Новый подписчик сразу получает актуальное значение, поэтому BLoC может
/// подписаться в любой момент и не пропустить данные.
class ValueStore<T> {
  ValueStore(this._value);

  T _value;
  final StreamController<T> _controller = StreamController<T>.broadcast();

  T get value => _value;

  Stream<T> get stream => Stream<T>.multi((controller) {
    controller.add(_value);
    final subscription = _controller.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  void emit(T next) {
    _value = next;
    _controller.add(next);
  }

  Future<void> dispose() => _controller.close();
}
