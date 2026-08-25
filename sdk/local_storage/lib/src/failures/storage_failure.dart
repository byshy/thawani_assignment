class StorageFailure implements Exception {
  const StorageFailure({this.message});

  final String? message;

  @override
  String toString() => message ?? 'StorageFailure';
}
