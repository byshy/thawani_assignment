import 'dart:async';

/// Limits how many async [action]s may run at the same time.
///
/// Used by [EpisodeRepositoryImpl] when fetching multiple episode chunks so
/// we do not open one socket per chunk (e.g. cap at 2 concurrent batch calls).
class ConcurrencyGate {
  ConcurrencyGate(this._max);

  /// Maximum number of [run] calls executing concurrently.
  final int _max;

  int _active = 0;
  final List<Completer<void>> _waiters = <Completer<void>>[];

  /// Waits for a slot if at capacity, runs [action], then releases the slot.
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
