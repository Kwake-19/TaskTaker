import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'timetable_tab.dart';
import 'todo_tab.dart';
import 'study_buddy_tab.dart';
import '../state/daily_progress.dart';
import '../state/selected_day.dart';
import '../services/windows_reminder_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final SupabaseClient _client = Supabase.instance.client;

  int _currentIndex = 1;

  String? _firstName;
  String? _level;
  String? _major;
  String? _semester;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WindowsReminderService.init();
      });
    } 

    WidgetsBinding.instance.addObserver(this);
    _loadUserContext();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🔁 Handle day change safely
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SelectedDay>().syncWithToday();
      context.read<DailyProgress>().resetIfNewDay();
    }
  }

  // ─────────────────────────────────────────────
  // LOAD USER DATA
  // ─────────────────────────────────────────────
  Future<void> _loadUserContext() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      final data = await _client
          .from('students')
          .select('first_name, level, major, semester')
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _firstName = data['first_name'];
        _level = data['level'];
        _major = data['major'];
        _semester = data['semester'];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleProfileUpdated() async {
    await _loadUserContext();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _firstName == null ||
        _level == null ||
        _major == null ||
        _semester == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = [
      const TimetableTab(),
      HomeTab(
        firstName: _firstName!,
        onViewTimetable: () => setState(() => _currentIndex = 0),
        onProfileUpdated: _handleProfileUpdated,
      ),
      const TodoTab(),
      const StudyBuddyTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F172A),
        unselectedItemColor: const Color(0xFF94A3B8),
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'To Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Study Buddy',
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////
/// 🌿 HOME TAB (MOTIVATIONAL + REAL PROGRESS)
////////////////////////////////////////////////
class HomeTab extends StatelessWidget {
  final String firstName;
  final VoidCallback onViewTimetable;
  final VoidCallback onProfileUpdated;

  const HomeTab({
    super.key,
    required this.firstName,
    required this.onViewTimetable,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyProgress>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, $firstName 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Let’s make today count.",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () async {
                  final updated =
                      await Navigator.pushNamed(context, '/profile');
                  if (updated == true && context.mounted) {
                    onProfileUpdated();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 36),

          /// 🔥 MOTIVATIONAL PROGRESS RING
          MotivationalProgressRing(
            progress: daily.progress,
            totalTasks: daily.totalTasks,
            completedTasks: daily.completedTasks,
          ),

          const SizedBox(height: 40),

          /// PRIMARY ACTION
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onViewTimetable,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "View Timetable",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////
/// 🌟 MOTIVATIONAL PROGRESS RING
////////////////////////////////////////////////
class MotivationalProgressRing extends StatelessWidget {
  final double progress;
  final int totalTasks;
  final int completedTasks;

  const MotivationalProgressRing({
    super.key,
    required this.progress,
    required this.totalTasks,
    required this.completedTasks,
  });

  String get _message {
    if (progress >= 1.0) return "Day conquered 🏆";
    if (progress >= 0.7) return "Almost there 💪";
    if (progress >= 0.3) return "You’re on a roll 🔥";
    return "Let’s get started 🚀";
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalTasks - completedTasks;

    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              backgroundColor:
                  const Color(0xFFCBD5E1).withValues(alpha: 0.4),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF14B8A6)),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(progress * 100).round()}%",
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F766E),
                  ),
                ),
                if (remaining > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    "$remaining task${remaining == 1 ? '' : 's'} left",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
