import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void _init() {
    _connectivity.checkConnectivity().then(_updateStatus);
    _connectivity.onConnectivityChanged.listen((results) {
      // connectivity_plus v6 emits List<ConnectivityResult>
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final bool online = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    return _isOnline;
  }

  void dispose() {
    _controller.close();
  }
}
