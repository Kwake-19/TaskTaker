import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class DailyProgress extends ChangeNotifier {
  double _progress = 0.0;

  double get progress => _progress;

  /// 🔄 Recalculate progress based on tasks
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

    notifyListeners();
  }

  /// Optional helper
  void reset() {
    _progress = 0.0;
    notifyListeners();
  }
}
