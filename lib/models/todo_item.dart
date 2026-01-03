class TodoItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isFromTimetable;
  bool completed;

  TodoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isFromTimetable,
    this.completed = false,
  });
}



