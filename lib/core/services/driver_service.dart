import 'dart:async';

class DriverService {
  static Timer? _timer;

  static void startService(Function onCheck) {
    if (_timer != null) return; // prevent multiple timers

    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      onCheck();
    });
  }

  static void stopService() {
    _timer?.cancel();
    _timer = null;
  }

  static bool isRunning() {
    return _timer != null;
  }
}
