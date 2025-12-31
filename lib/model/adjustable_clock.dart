import 'package:clock/clock.dart';

/// A clock that can be adjusted setting the time or changing the speed.
class AdjustableClock extends Clock {
  DateTime _startTime;
  DateTime _anchorTime;
  double _rate;

  AdjustableClock([DateTime? startTime])
      : _startTime = startTime ?? DateTime.now(),
        _anchorTime = DateTime.now(),
        _rate = 1.0;

  @override
  DateTime now() {
    final elapsed = DateTime.now().difference(_anchorTime);
    return _startTime.add(elapsed * _rate);
  }

  /// Sets the current time of the clock.
  /// The clock will continue to tick from this time at the current rate.
  void setTime(DateTime time) {
    _startTime = time;
    _anchorTime = DateTime.now();
  }

  /// Sets the speed multiplier of the clock.
  /// 1.0 is normal speed. 60.0 is 1 minute per second.
  void setRate(double rate) {
    if (_rate == rate) return;
    
    // Capture the current virtual time to use as the new start time
    // so the clock doesn't jump wildly when changing rate.
    _startTime = now();
    _anchorTime = DateTime.now();
    _rate = rate;
  }
  
  /// Helper to determine if we are effectively using system time.
  bool get isSystemTime => _rate == 1.0 && _startTime.difference(_anchorTime).inMilliseconds.abs() < 100; 
  // Note: Detecting "system time" accurately after drifting is hard with this model unless we keep a flag.
  // The SettingsController can track the "mode".
}
