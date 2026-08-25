enum CharacterStatus {
  alive,
  dead,
  unknown;

  static CharacterStatus fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'alive':
        return CharacterStatus.alive;
      case 'dead':
        return CharacterStatus.dead;
      default:
        return CharacterStatus.unknown;
    }
  }

  String toApi() {
    switch (this) {
      case CharacterStatus.alive:
        return 'Alive';
      case CharacterStatus.dead:
        return 'Dead';
      case CharacterStatus.unknown:
        return 'unknown';
    }
  }
}
