sealed class RemoteFailure implements Exception {
  const RemoteFailure({this.message});

  final String? message;

  @override
  String toString() => message ?? runtimeType.toString();
}

/// No connectivity, timeout, or socket failure.
class NetworkFailure extends RemoteFailure {
  const NetworkFailure({super.message});
}

/// Unexpected HTTP status (except cases the caller treats specially, e.g. search 404).
class ServerFailure extends RemoteFailure {
  const ServerFailure({super.message, this.statusCode});

  final int? statusCode;
}

/// Response body could not be parsed as expected JSON.
class ParseFailure extends RemoteFailure {
  const ParseFailure({super.message});
}

/// Request was cancelled (e.g. dispose / stale search).
class CancelledFailure extends RemoteFailure {
  const CancelledFailure({super.message});
}
