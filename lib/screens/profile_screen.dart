import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock data (UI-only)
  final String _fullName = "Arabella Kwake";
  final String _institution = "ICT University";
  final String _matricule = "ICTU20241518";

  String _selectedLevel = "200";
  String _selectedMajor = "Software Engineering";
  String _selectedSemester = "Fall";

  final List<String> _levels = ["100", "200", "300", "400"];
  final List<String> _majors = [
    "Computer Science",
    "Software Engineering",
    "Information Systems",
    "Cyber Security",
    "Data Science",
  ];
  final List<String> _semesters = ["Fall", "Spring"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              /// 👤 HEADER CARD
              _profileHeader(),

              const SizedBox(height: 32),

              /// 🏫 STUDENT INFO
              _sectionTitle("Student Information"),
              _infoTile("Full name", _fullName),
              _infoTile("Institution", _institution),
              _infoTile("Matricule", _matricule),

              const SizedBox(height: 32),

              /// 🎓 ACADEMIC CONTEXT
              _sectionTitle("Academic Context"),
              _dropdownField(
                label: "Level",
                value: _selectedLevel,
                items: _levels,
                onChanged: (value) {
                  setState(() => _selectedLevel = value!);
                },
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: "Major",
                value: _selectedMajor,
                items: _majors,
                onChanged: (value) {
                  setState(() => _selectedMajor = value!);
                },
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: "Semester",
                value: _selectedSemester,
                items: _semesters,
                onChanged: (value) {
                  setState(() => _selectedSemester = value!);
                },
              ),

              const SizedBox(height: 40),

              /// 💾 SAVE BUTTON
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TO_DO: Later: save + reload timetable
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // UI COMPONENTS
  // ─────────────────────────────

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                const Color(0xFF14B8A6).withValues(alpha: 0.15),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _institution,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
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

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
