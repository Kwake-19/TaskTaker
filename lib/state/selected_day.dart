import 'package:flutter/material.dart';

class SelectedDay extends ChangeNotifier {
  String _day;
  DateTime _date;

  SelectedDay()
      : _date = DateTime.now(),
        _day = _dayFromDate(DateTime.now());

  String get day => _day;

  /// User manually changes day
  void setDay(String newDay) {
    _day = newDay;
    notifyListeners();
  }

  /// Called when app resumes or day changes
  void syncWithToday() {
    final now = DateTime.now();

    if (!_isSameDate(now, _date)) {
      _date = now;
      _day = _dayFromDate(now);
      notifyListeners();
    }
  }

  // ─────────────────────────────
  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static String _dayFromDate(DateTime date) {
    const map = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return map[date.weekday]!;
  }
}

