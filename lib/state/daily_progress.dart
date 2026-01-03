import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class DailyProgress extends ChangeNotifier {
  double _progress = 0.0;
  DateTime _lastCalculatedDate = DateTime.now();

  double get progress => _progress;

  // ─────────────────────────────
  // 🔄 RESET IF A NEW REAL DAY STARTED
  // ─────────────────────────────
  void resetIfNewDay() {
    final now = DateTime.now();

    final isNewDay =
        now.year != _lastCalculatedDate.year ||
        now.month != _lastCalculatedDate.month ||
        now.day != _lastCalculatedDate.day;

    if (isNewDay) {
      _progress = 0.0;
      _lastCalculatedDate = now;
      notifyListeners();
    }
  }

  // ─────────────────────────────
  // 📊 RECALCULATE DAILY PROGRESS
  // ─────────────────────────────
  void recalculate({
    required List<TodoItem> timetableTasks,
    required List<TodoItem> personalTasks,
  }) {
    final allTasks = [...timetableTasks, ...personalTasks];

    if (allTasks.isEmpty) {
      _progress = 0.0;
    } else {
      final completed =
          allTasks.where((task) => task.completed).length;
      _progress = completed / allTasks.length;
    }

    _lastCalculatedDate = DateTime.now();
    notifyListeners();
  }
}
