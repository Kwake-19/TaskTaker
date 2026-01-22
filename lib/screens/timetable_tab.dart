import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timetable_service.dart';
import '../models/timetable_entry.dart';
import '../state/selected_day.dart';

class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key});

  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  int _selectedDayIndex = 0;

  /// ✅ NOW INCLUDES WEEKENDS
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late Future<List<TimetableEntry>> _timetableFuture;

  @override
  void initState() {
    super.initState();
    _loadTimetable();

    /// 🔑 Sync with global selected day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDay = context.read<SelectedDay>().day;
      final index = _days.indexOf(selectedDay);
      if (index != -1) {
        setState(() => _selectedDayIndex = index);
      }
    });
  }

  void _loadTimetable() {
    _timetableFuture = TimetableService.getTimetable();
  }

  /// 🔄 Pull-to-refresh handler
  Future<void> _refresh() async {
    setState(() {
      _loadTimetable();
    });
    await _timetableFuture;
  }

  /// 🔑 Normalize DB day strings
  String normalizeDay(String day) {
    final d = day.trim().toLowerCase();
    if (d.startsWith('mon')) return 'Monday';
    if (d.startsWith('tue')) return 'Tuesday';
    if (d.startsWith('wed')) return 'Wednesday';
    if (d.startsWith('thu')) return 'Thursday';
    if (d.startsWith('fri')) return 'Friday';
    if (d.startsWith('sat')) return 'Saturday';
    if (d.startsWith('sun')) return 'Sunday';
    return day;
  }

  bool _isWeekend(String day) {
    return day == 'Saturday' || day == 'Sunday';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Timetable",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 20),

            /// 📆 DAY SELECTOR
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;

                  return GestureDetector(
                    onTap: () {
                      context
                          .read<SelectedDay>()
                          .setDay(_days[index]);

                      setState(() => _selectedDayIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _days[index].substring(0, 3),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// 📚 TIMETABLE CONTENT
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<TimetableEntry>>(
                  future: _timetableFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }

                    final timetable = snapshot.data ?? [];
                    final selectedDay = _days[_selectedDayIndex];

                    /// 🟢 WEEKEND HANDLING
                    if (_isWeekend(selectedDay)) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Icon(
                            Icons.weekend,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              "No classes (Weekend 🎉)",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final dayClasses = timetable.where((entry) {
                      return normalizeDay(entry.day) == selectedDay;
                    }).toList();

                    if (dayClasses.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              "No classes today",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: dayClasses.length,
                      itemBuilder: (context, index) {
                        return _ClassCard(entry: dayClasses[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🧱 CLASS CARD
class _ClassCard extends StatelessWidget {
  final TimetableEntry entry;

  const _ClassCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.course,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text("${entry.startTime} - ${entry.endTime}"),
                const SizedBox(height: 6),
                Text(entry.location),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
