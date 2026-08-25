import 'package:local_storage/local_storage.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

String failureMessage(Object error) {
  return switch (error) {
    NoCachedDataFailure() =>
      'Unavailable offline. Connect to the internet and retry.',
    NetworkFailure() => 'No internet connection. Check your network and retry.',
    ServerFailure() => 'Something went wrong on the server. Please retry.',
    ParseFailure() => 'Could not read the response. Please retry.',
    StorageFailure() => 'Could not read saved data. Please retry.',
    _ => 'Something went wrong. Please retry.',
  };
}
