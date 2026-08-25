import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:networking/networking.dart';

import 'network_state.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkProvider({
    required Stream<bool> onStatusChanged,
    Future<bool>? currentStatus,
    NetworkStatus initialStatus = NetworkStatus.unknown,
  }) : _state = NetworkState(status: initialStatus) {
    _subscription = onStatusChanged.listen(_onStatus);
    final pending = currentStatus;
    if (pending != null) {
      unawaited(_seed(pending));
    }
  }

  factory NetworkProvider.fromChecker(ConnectivityChecker connectivity) {
    return NetworkProvider(
      onStatusChanged: connectivity.onStatusChanged,
      currentStatus: connectivity.isOnline,
    );
  }

  StreamSubscription<bool>? _subscription;
  var _disposed = false;

  NetworkState _state;
  NetworkState get state => _state;

  void _emit(NetworkState next) {
    if (next.status == _state.status) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  Future<void> _seed(Future<bool> currentStatus) async {
    final online = await currentStatus;
    if (_disposed) {
      return;
    }
    _onStatus(online);
  }

  void _onStatus(bool online) {
    _emit(
      _state.copyWith(
        status: online ? NetworkStatus.online : NetworkStatus.offline,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
