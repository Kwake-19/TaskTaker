import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class DailyProgress extends ChangeNotifier {
  int _totalTasks = 0;
  int _completedTasks = 0;
  DateTime _lastUpdated = DateTime.now();

  // ───────────── GETTERS ─────────────
  double get progress {
    if (_totalTasks == 0) return 0.0;
    return _completedTasks / _totalTasks;
  }

  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;

  // ───────────── CALCULATE ─────────────
  void recalculate({
    required List<TodoItem> timetableTasks,
    required List<TodoItem> personalTasks,
  }) {
    final allTasks = [...timetableTasks, ...personalTasks];

    _totalTasks = allTasks.length;
    _completedTasks =
        allTasks.where((task) => task.completed).length;

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // ───────────── DAILY RESET ─────────────
  void resetIfNewDay() {
    final now = DateTime.now();

    if (!_isSameDay(now, _lastUpdated)) {
      _totalTasks = 0;
      _completedTasks = 0;
      _lastUpdated = now;
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}
