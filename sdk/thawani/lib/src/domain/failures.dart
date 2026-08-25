/// Offline with no usable cache for the requested data.
class NoCachedDataFailure implements Exception {
  const NoCachedDataFailure({
    this.message = 'No cached data available offline',
  });

  final String? message;

  @override
  String toString() => message ?? 'NoCachedDataFailure';
}
