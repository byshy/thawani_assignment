class CacheMeta {
  const CacheMeta({
    required this.fetchedAt,
    this.fromCache = true,
  });

  final DateTime fetchedAt;
  final bool fromCache;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CacheMeta &&
            fetchedAt == other.fetchedAt &&
            fromCache == other.fromCache;
  }

  @override
  int get hashCode => Object.hash(fetchedAt, fromCache);
}
