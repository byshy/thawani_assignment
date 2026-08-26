import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

class GetEpisodesUseCase {
  GetEpisodesUseCase(this._repository);

  final EpisodeRepository _repository;

  Stream<EpisodesSnapshot> call(List<int> ids, {CancelToken? cancelToken}) {
    return _repository.watchEpisodes(ids, cancelToken: cancelToken);
  }
}
