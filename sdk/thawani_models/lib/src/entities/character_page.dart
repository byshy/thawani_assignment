import 'character.dart';
import 'page_info.dart';

class CharacterPage {
  const CharacterPage({
    required this.info,
    required this.results,
  });

  final PageInfo info;
  final List<Character> results;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CharacterPage &&
            info == other.info &&
            _listEquals(results, other.results);
  }

  @override
  int get hashCode => Object.hash(info, Object.hashAll(results));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
