import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_item.dart';

class TaskService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// 📥 Load personal tasks for a given day
  static Future<List<TodoItem>> getTasksForDay(String day) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .eq('day_of_week', day)
        .order('created_at');

    return response.map<TodoItem>((row) {
      return TodoItem(
        id: row['id'],
        title: row['title'],
        subtitle: row['time'] == null
            ? 'Personal task'
            : '${row['time']} · Personal task',
        completed: row['completed'] ?? false,
        isFromTimetable: false,
      );
    }).toList();
  }

  /// ➕ Add a new personal task
  /// ✅ Stores notify_at for server push notifications
  /// ✅ RETURNS THE CREATED TASK ID
  static Future<String> addTask({
    required String title,
    required String day,
    String? time,
    DateTime? notifyAt, // 👈 NEW
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final response = await _client
        .from('tasks')
        .insert({
          'user_id': user.id,
          'title': title,
          'day_of_week': day,
          'time': time,
          'completed': false,
          'notify_at': notifyAt?.toIso8601String(), // 👈 NEW
          'notification_sent': false,               // 👈 NEW
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// ✅ Toggle completion
  /// Cancels server notification if completed early
  static Future<void> toggleTask(
    String taskId,
    bool completed,
  ) async {
    await _client
        .from('tasks')
        .update({
          'completed': completed,
          if (completed) 'notification_sent': true,
        })
        .eq('id', taskId);
  }

  /// 🗑 Delete a task
  static Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
