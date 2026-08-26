import 'dart:async';

/// Limits how many async [action]s run at once.
class ConcurrencyGate {
  ConcurrencyGate(this._max);

  final int _max;
  int _active = 0;
  final List<Completer<void>> _waiters = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() action) async {
    if (_active >= _max) {
      final Completer<void> waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await action();
    } finally {
      _active--;
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete();
      }
    }
  }
}
