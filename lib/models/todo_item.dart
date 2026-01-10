class TodoItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isFromTimetable;
  bool completed;

   /// OPTIONAL — used for reminders
  final DateTime? scheduledDateTime;
  final String? time;

  TodoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isFromTimetable,
    this.completed = false,
     this.scheduledDateTime,
     this.time,
  });
}



