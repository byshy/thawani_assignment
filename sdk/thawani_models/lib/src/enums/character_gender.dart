enum CharacterGender {
  female,
  male,
  genderless,
  unknown;

  static CharacterGender fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'female':
        return CharacterGender.female;
      case 'male':
        return CharacterGender.male;
      case 'genderless':
        return CharacterGender.genderless;
      default:
        return CharacterGender.unknown;
    }
  }
}
