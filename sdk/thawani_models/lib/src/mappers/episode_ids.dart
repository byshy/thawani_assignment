/// Parses `/api/episode/12` (any host) into `12`. Invalid URLs are skipped.
int? episodeIdFromUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.pathSegments.isEmpty) {
    return null;
  }
  return int.tryParse(uri.pathSegments.last);
}

List<int> episodeIdsFromUrls(Iterable<String> urls) {
  final seen = <int>{};
  final ids = <int>[];
  for (final url in urls) {
    final id = episodeIdFromUrl(url);
    if (id != null && seen.add(id)) {
      ids.add(id);
    }
  }
  return ids;
}
