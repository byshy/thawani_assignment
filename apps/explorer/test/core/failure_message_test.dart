import 'package:explorer/core/failure_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

void main() {
  test('maps typed failures to user-facing copy', () {
    expect(
      failureMessage(const NoCachedDataFailure()),
      contains('Unavailable offline'),
    );
    expect(failureMessage(const NetworkFailure()), contains('internet'));
    expect(failureMessage(const ServerFailure()), contains('server'));
    expect(failureMessage(const ParseFailure()), contains('read the response'));
    expect(failureMessage(const StorageFailure()), contains('saved data'));
    expect(failureMessage(Exception('nope')), contains('Something went wrong'));
  });
}
