import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../services/timetable_service.dart';
import '../services/task_service.dart';
import '../state/selected_day.dart';
import '../state/daily_progress.dart';

class TodoTab extends StatefulWidget {
  const TodoTab({super.key});

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  List<TodoItem> _timetableTasks = [];
  List<TodoItem> _personalTasks = [];

  bool _loadingTimetable = true;
  bool _loadingPersonal = true;

  String? _lastDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final day = context.watch<SelectedDay>().day;
    if (_lastDay != day) {
      _lastDay = day;
      _loadTimetable(day);
      _loadPersonalTasks(day);
    }
  }

  // ─────────────────────────────────────────────
  // LOAD DATA
  // ─────────────────────────────────────────────

  Future<void> _loadTimetable(String day) async {
    setState(() => _loadingTimetable = true);

    final tasks = await TimetableService.getTodoTasksForDay(day);
    if (!mounted) return;

    setState(() {
      _timetableTasks = tasks;
      _loadingTimetable = false;
    });

    _recalculateProgress();
  }

  Future<void> _loadPersonalTasks(String day) async {
    setState(() => _loadingPersonal = true);

    final tasks = await TaskService.getTasksForDay(day);
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

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        onPressed: _showAddTaskPopup,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
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
                const Center(child: CircularProgressIndicator())
              else if (_timetableTasks.isEmpty)
                const Text("No classes this day 🎉")
              else
                ..._timetableTasks.map(_taskCard),

              const SizedBox(height: 32),

              _sectionTitle("My Tasks"),

              if (_loadingPersonal)
                const Center(child: CircularProgressIndicator())
              else if (_personalTasks.isEmpty)
                _emptyPersonal()
              else
                Column(
                  children:
                      _personalTasks.map(_dismissibleTask).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // COMPONENTS
  // ─────────────────────────────────────────────

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

  /// ✅ FIXED: Timetable tasks are now checkable
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

              // 🔒 Persist ONLY personal tasks
              if (!item.isFromTimetable) {
                await TaskService.toggleTask(item.id, v);
              }

              if (!mounted) return;
              _recalculateProgress();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration:
                        item.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: Colors.grey),
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
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) async {
        final day = _lastDay;
        await TaskService.deleteTask(item.id);

        if (!mounted || day == null) return;
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

  // ─────────────────────────────────────────────
  // ADD TASK POPUP
  // ─────────────────────────────────────────────

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
                          icon: const Icon(Icons.access_time),
                          label: const Text("Pick time"),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (t != null) setModal(() => time = t);
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
                          final title = controller.text.trim();
                          if (title.isEmpty) return;

                          await TaskService.addTask(
                            title: title,
                            day: day,
                            time: time?.format(context),
                          );

                          if (!mounted) return;
                          await _loadPersonalTasks(day);
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text("Add Task"),
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
