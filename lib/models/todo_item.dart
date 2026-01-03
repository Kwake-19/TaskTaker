class TodoItem {
  final String title;
  final String subtitle;
  bool completed;
  final bool isFromTimetable;


  TodoItem({
    required this.title,
    required this.subtitle,
    this.completed = false,
    required this.isFromTimetable,
  });
}





