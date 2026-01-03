import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/timetable_entry.dart';
import '../models/todo_item.dart';

class TimetableService {
  static final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // FETCH FULL TIMETABLE FOR CURRENT STUDENT
  // =====================================================
  static Future<List<TimetableEntry>> getTimetable() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // 1️⃣ Fetch student profile
    final student = await _client
        .from('students')
        .select('level, major, semester')
        .eq('id', user.id)
        .single();

    final String level = student['level'].toString();
    final String major = student['major'].toString();
    final String semester = student['semester'].toString();

    // 2️⃣ Fetch timetable entries (LEFT JOIN SAFE)
    final response = await _client
        .from('timetable_entries')
        .select('''
          day_of_week,
          start_time,
          end_time,
          venue,
          course_offerings(
            level,
            major,
            semester,
            is_common,
            courses(name)
          )
        ''')
        .eq('course_offerings.level', level)
        .eq('course_offerings.major', major)
        .eq('course_offerings.semester', semester);

    final List<TimetableEntry> results = [];

    for (final row in response) {
      final offering = row['course_offerings'];
      if (offering == null) continue;

      final course = offering['courses'];
      if (course == null) continue;

      results.add(
        TimetableEntry(
          course: course['name'].toString(),
          day: _normalizeDay(row['day_of_week'].toString()),
          startTime: row['start_time'].toString(),
          endTime: row['end_time'].toString(),
          location: row['venue'].toString(),
        ),
      );
    }

    return results;
  }

  // =====================================================
  // CONVERT TIMETABLE → TODOTASKS (FOR ANY DAY)
  // =====================================================
  static Future<List<TodoItem>> getTodoTasksForDay(String selectedDay) async {
    final timetable = await getTimetable();

    final dayClasses = timetable.where((entry) {
      return entry.day.toLowerCase() ==
          selectedDay.toLowerCase();
    });

    return dayClasses.map((entry) {
      return TodoItem(
        // ✅ GENERATED STABLE ID
        id: 'tt_${entry.course}_${entry.day}_${entry.startTime}',

        title: 'Attend ${entry.course}',
        subtitle:
            '${entry.startTime} – ${entry.endTime} · ${entry.location}',

        completed: false,
        isFromTimetable: true,
      );
    }).toList();
  }

  // =====================================================
  // CONVENIENCE: TODAY'S TASKS
  // =====================================================
  static Future<List<TodoItem>> getTodayTodoTasks() async {
    final today = DateTime.now().weekday;

    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
    };

    final todayName = days[today];
    if (todayName == null) return [];

    return getTodoTasksForDay(todayName);
  }

  // =====================================================
  // DAY NORMALIZATION (DB SAFETY)
  // =====================================================
  static String _normalizeDay(String day) {
    final d = day.trim().toLowerCase();

    if (d.startsWith('mon')) return 'Monday';
    if (d.startsWith('tue')) return 'Tuesday';
    if (d.startsWith('wed')) return 'Wednesday';
    if (d.startsWith('thu')) return 'Thursday';
    if (d.startsWith('fri')) return 'Friday';

    return day;
  }
}

