import 'package:flutter/material.dart';

class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key});

  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  int _selectedDayIndex = 0;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  /// 🧪 DUMMY TIMETABLE DATA (UI ONLY)
  final Map<String, List<Map<String, String>>> _timetable = {
    'Mon': [
      {
        'course': 'Data Structures',
        'time': '08:00 - 10:00',
        'venue': 'Lab 1',
        'type': 'Lecture',
      },
      {
        'course': 'Discrete Mathematics',
        'time': '11:00 - 13:00',
        'venue': 'Room B2',
        'type': 'Tutorial',
      },
    ],
    'Tue': [
      {
        'course': 'Software Engineering',
        'time': '09:00 - 11:00',
        'venue': 'Room C1',
        'type': 'Lecture',
      },
    ],
    'Wed': [],
    'Thu': [
      {
        'course': 'Computer Networks',
        'time': '14:00 - 16:00',
        'venue': 'Lab 2',
        'type': 'Practical',
      },
    ],
    'Fri': [
      {
        'course': 'Cyber Security',
        'time': '10:00 - 12:00',
        'venue': 'Room A3',
        'type': 'Lecture',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedDay = _days[_selectedDayIndex];
    final classes = _timetable[selectedDay]!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔝 HEADER
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
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDayIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _days[index],
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

            /// 📚 CLASSES LIST
            Expanded(
              child: classes.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        return _ClassCard(
                          course: c['course']!,
                          time: c['time']!,
                          venue: c['venue']!,
                          type: c['type']!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_available,
              size: 48, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            "No classes today",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🧱 CLASS CARD WIDGET
class _ClassCard extends StatelessWidget {
  final String course;
  final String time;
  final String venue;
  final String type;

  const _ClassCard({
    required this.course,
    required this.time,
    required this.venue,
    required this.type,
  });

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
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ⏱ TIME BAR
          Container(
            width: 6,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 14),

          /// 📘 DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      venue,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    _typeChip(type),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF14B8A6),
        ),
      ),
    );
  }
}
