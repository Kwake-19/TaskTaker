import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class WindowsReminderService {
  static final Map<int, DateTime> _scheduled = {};
  static Timer? _timer;

  static void init() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _check(),
    );
  }

  static void schedule({
    required int id,
    required String title,
    required DateTime time,
  }) {
    _scheduled[id] = time;
  }

  static void cancel(int id) {
    _scheduled.remove(id);
  }

  static void _check() {
    final now = DateTime.now();

    final due = _scheduled.entries.where(
      (e) => now.isAfter(e.value),
    ).toList();

    for (final entry in due) {
      _scheduled.remove(entry.key);

      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) return;

      navigator.push(
        DialogRoute(
          context: navigator.context,
          builder: (_) => AlertDialog(
            title: const Text("⏰ Task Reminder"),
            content: const Text("It's time for your task"),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
