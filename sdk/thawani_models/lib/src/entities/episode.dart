class Episode {
  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    this.url = '',
  });

  final int id;
  final String name;
  final String airDate;
  final String code;
  final String url;

  /// Season number from codes like `S01E01`. `0` when the code is not parseable.
  int get season {
    final match = RegExp(r'^S(\d+)', caseSensitive: false).firstMatch(code);
    if (match == null) {
      return 0;
    }
    return int.parse(match.group(1)!);
  }

  int get episodeNumber {
    final match = RegExp(r'E(\d+)$', caseSensitive: false).firstMatch(code);
    if (match == null) {
      return id;
    }
    return int.parse(match.group(1)!);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Episode &&
            id == other.id &&
            name == other.name &&
            airDate == other.airDate &&
            code == other.code &&
            url == other.url;
  }

  @override
  int get hashCode => Object.hash(id, name, airDate, code, url);
}
