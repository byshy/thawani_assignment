import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Checks real internet reachability (not just Wi‑Fi/cellular attachment).
class ConnectivityChecker {
  ConnectivityChecker({InternetConnection? connection})
      : _connection = connection ?? InternetConnection.createInstance(),
        _ownsConnection = connection == null;

  final InternetConnection _connection;
  final bool _ownsConnection;

  Future<bool> get isOnline => _connection.hasInternetAccess;

  Stream<bool> get onStatusChanged {
    return _connection.onStatusChange.map(
      (status) => status == InternetStatus.connected,
    );
  }

  Future<void> dispose() async {
    if (_ownsConnection) {
      await _connection.dispose();
    }
  }
}
