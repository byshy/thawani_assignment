class CharacterLocation {
  const CharacterLocation({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CharacterLocation && name == other.name && url == other.url;
  }

  @override
  int get hashCode => Object.hash(name, url);
}
