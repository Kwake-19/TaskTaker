import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../services/timetable_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../services/windows_reminder_service.dart';
import '../state/selected_day.dart';
import '../state/daily_progress.dart';

class TodoTab extends StatefulWidget {
  const TodoTab({super.key});

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab>
    with WidgetsBindingObserver {
  List<TodoItem> _timetableTasks = [];
  List<TodoItem> _personalTasks = [];

  bool _loadingTimetable = true;
  bool _loadingPersonal = true;

  String? _lastDay;

  /// Stable notification ID per task (for LOCAL notifications only)
  int _notificationId(String taskId) =>
      taskId.hashCode & 0x7fffffff;

  AppLifecycleState _lifecycleState =
      AppLifecycleState.resumed;

  bool get _isAppInForeground =>
      _lifecycleState == AppLifecycleState.resumed;

  // ───────────────── LIFECYCLE ─────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
  }

  // ───────────────── DAY CHANGES ─────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final day = context.watch<SelectedDay>().day;
    if (_lastDay != day) {
      _lastDay = day;
      _reloadAll(day);
    }
  }

  // ───────────────── LOAD DATA ─────────────────

  Future<void> _reloadAll(String day) async {
    await Future.wait([
      _loadTimetable(day),
      _loadPersonalTasks(day),
    ]);
  }

  Future<void> _loadTimetable(String day) async {
    setState(() => _loadingTimetable = true);

    final tasks =
        await TimetableService.getTodoTasksForDay(day);
    if (!mounted) return;

    setState(() {
      _timetableTasks = tasks;
      _loadingTimetable = false;
    });

    _recalculateProgress();
  }

  Future<void> _loadPersonalTasks(String day) async {
    setState(() => _loadingPersonal = true);

    final tasks =
        await TaskService.getTasksForDay(day);
    if (!mounted) return;

    setState(() {
      _personalTasks = tasks;
      _loadingPersonal = false;
    });

    _recalculateProgress();
  }

  void _recalculateProgress() {
    context.read<DailyProgress>().recalculate(
      timetableTasks: _timetableTasks,
      personalTasks: _personalTasks,
    );
  }

  // ───────────────── DATE CALCULATION ─────────────────

  DateTime _nextDateForWeekday(
      String weekday, TimeOfDay time) {
    final now = DateTime.now();

    const map = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    final target = map[weekday]!;

    final todayCandidate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (now.weekday == target &&
        todayCandidate.isAfter(now)) {
      return todayCandidate;
    }

    int diff = target - now.weekday;
    if (diff <= 0) diff += 7;

    final next = now.add(Duration(days: diff));
    return DateTime(
      next.year,
      next.month,
      next.day,
      time.hour,
      time.minute,
    );
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final day = context.watch<SelectedDay>().day;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        onPressed: _showAddTaskPopup,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _reloadAll(day),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle("From Timetable"),
                if (_loadingTimetable)
                  const Center(
                      child: CircularProgressIndicator())
                else if (_timetableTasks.isEmpty)
                  const Text("No classes this day 🎉")
                else
                  ..._timetableTasks.map(_taskCard),

                const SizedBox(height: 32),

                _sectionTitle("My Tasks"),
                if (_loadingPersonal)
                  const Center(
                      child: CircularProgressIndicator())
                else if (_personalTasks.isEmpty)
                  _emptyPersonal()
                else
                  Column(
                    children: _personalTasks
                        .map(_dismissibleTask)
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── COMPONENTS ─────────────────

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _taskCard(TodoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.completed,
            onChanged: (v) async {
              if (v == null) return;

              setState(() => item.completed = v);

              if (!item.isFromTimetable) {
                await TaskService.toggleTask(
                    item.id, v);

                if (v) {
                  await NotificationService.cancel(
                    _notificationId(item.id),
                  );
                }
              }

              if (!mounted) return;
              _recalculateProgress();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: item.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dismissibleTask(TodoItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.only(right: 24),
        color: Colors.red.withValues(alpha: .15),
        child:
            const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) async {
        final day = _lastDay;
        if (day == null) return;

        await TaskService.deleteTask(item.id);
        await NotificationService.cancel(
          _notificationId(item.id),
        );

        if (!mounted) return;
        await _loadPersonalTasks(day);
      },
      child: _taskCard(item),
    );
  }

  Widget _emptyPersonal() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "No personal tasks yet.\nTap + to add one.",
        textAlign: TextAlign.center,
      ),
    );
  }

  // ───────────────── ADD TASK POPUP ─────────────────

  void _showAddTaskPopup() {
    final controller = TextEditingController();
    TimeOfDay? time;
    final day = context.read<SelectedDay>().day;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (_, setModal) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Task",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Task title",
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            time == null
                                ? "No time selected"
                                : time!.format(context),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                              Icons.access_time),
                          label:
                              const Text("Pick time"),
                          onPressed: () async {
                            final t =
                                await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.now(),
                            );
                            if (t != null) {
                              setModal(() => time = t);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title =
                              controller.text.trim();
                          if (title.isEmpty) return;

                          Navigator.of(dialogContext)
                              .pop();

                          DateTime? notifyAt;
                          if (time != null) {
                            notifyAt =
                                _nextDateForWeekday(
                                    day, time!)
                                    .toUtc();
                          }

                          final taskId =
                              await TaskService.addTask(
                            title: title,
                            day: day,
                            time:
                                time?.format(context),
                            notifyAt: notifyAt,
                          );

                          // LOCAL notification (kept)
                          if (notifyAt != null) {
                            if (Platform.isWindows) {
                              WindowsReminderService
                                  .schedule(
                                id: _notificationId(
                                    taskId),
                                title: title,
                                time: notifyAt
                                    .toLocal(),
                              );
                            } else {
                              await NotificationService
                                  .schedule(
                                id: _notificationId(
                                    taskId),
                                title: title,
                                time: notifyAt
                                    .toLocal(),
                                onInAppReminder:
                                    _isAppInForeground
                                        ? () {
                                            if (!mounted) {
                                              return;
                                            }
                                            showDialog(
                                              context:
                                                  context,
                                              builder:
                                                  (_) =>
                                                      AlertDialog(
                                                title:
                                                    const Text(
                                                        "⏰ Task Reminder"),
                                                content:
                                                    Text(
                                                        title),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.pop(
                                                                context),
                                                    child:
                                                        const Text(
                                                            "OK"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        : null,
                              );
                            }
                          }

                          if (!mounted) return;
                          await _loadPersonalTasks(
                              day);
                        },
                        child:
                            const Text("Add Task"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
