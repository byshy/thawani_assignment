enum NetworkStatus { unknown, online, offline }

class NetworkState {
  const NetworkState({this.status = NetworkStatus.unknown});

  final NetworkStatus status;

  bool get isOnline => status == NetworkStatus.online;
  bool get isOffline => status == NetworkStatus.offline;

  NetworkState copyWith({NetworkStatus? status}) {
    return NetworkState(status: status ?? this.status);
  }
}
