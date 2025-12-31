import 'package:flutter/material.dart';

class TodoTab extends StatefulWidget {
  const TodoTab({super.key});

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  final List<_TodoItem> _timetableTasks = [
    _TodoItem(
      title: 'Attend Computer Networks class',
      subtitle: '10:00 – 12:00 · Room A3',
      completed: false,
      isFromTimetable: true,
    ),
    _TodoItem(
      title: 'Attend Software Engineering lecture',
      subtitle: '14:00 – 16:00 · Room C1',
      completed: false,
      isFromTimetable: true,
    ),
  ];

  final List<_TodoItem> _personalTasks = [
    _TodoItem(
      title: 'Revise Data Structures',
      subtitle: 'Before 9 PM',
      completed: false,
      isFromTimetable: false,
    ),
    _TodoItem(
      title: 'Submit assignment',
      subtitle: 'Due tonight',
      completed: true,
      isFromTimetable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        onPressed: _showAddTaskSheet,
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
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle("From Timetable"),
              ..._timetableTasks.map(_lockedTaskCard),

              const SizedBox(height: 32),

              _sectionTitle("My Tasks"),
              _personalTasks.isEmpty
                  ? _emptyPersonalTasks()
                  : Column(
                      children: _personalTasks
                          .map(_dismissibleTaskCard)
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  /// 🔒 Timetable task (not dismissible)
  Widget _lockedTaskCard(_TodoItem item) {
    return _taskCard(item);
  }

  /// 🧹 Personal task (dismissible)
  Widget _dismissibleTaskCard(_TodoItem item) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(
        icon: Icons.check,
        color: Colors.green,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBackground(
        icon: Icons.delete,
        color: Colors.red,
        alignment: Alignment.centerRight,
      ),
      onDismissed: (_) {
        setState(() {
          _personalTasks.remove(item);
        });
      },
      child: _taskCard(item),
    );
  }

  /// 🧱 Shared task card UI
  Widget _taskCard(_TodoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.completed,
            activeColor: const Color(0xFF14B8A6),
            onChanged: (value) {
              setState(() => item.completed = value ?? false);
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration:
                        item.completed ? TextDecoration.lineThrough : null,
                    color: item.completed
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                _originChip(item.isFromTimetable),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _originChip(bool fromTimetable) {
    return Chip(
      label: Text(fromTimetable ? 'From Timetable' : 'Personal'),
      backgroundColor:
          const Color(0xFF14B8A6).withValues(alpha: 0.15),
      labelStyle: const TextStyle(
        color: Color(0xFF14B8A6),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _swipeBackground({
    required IconData icon,
    required Color color,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color),
    );
  }

  Widget _emptyPersonalTasks() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "No personal tasks yet.\nTap + to add one.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SizedBox(height: 200),
    );
  }
}

/// 🧠 SIMPLE TODO MODEL (UI ONLY)
class _TodoItem {
  final String title;
  final String subtitle;
  bool completed;
  final bool isFromTimetable;

  _TodoItem({
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.isFromTimetable,
  });
}
