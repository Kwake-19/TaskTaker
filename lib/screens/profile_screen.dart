import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Loaded from backend ───
  String _fullName = '';
  String _institution = '';
  String _matricule = '';
  String _userId = '';

  // ─── Editable ───
  String? _selectedLevel;
  String? _selectedMajor;
  String? _selectedSemester;

  bool _isLoading = true;

  final List<String> _levels = ['100', '200', '300', '400'];
  final List<String> _majors = ['CS', 'SEN', 'ISN', 'CYS', 'ICT'];
  final List<String> _semesters = ['Fall', 'Spring'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ─────────────────────────────
  // LOAD PROFILE (SAFE)
  // ─────────────────────────────
  Future<void> _loadProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      _userId = user.id;

      final data = await _client
          .from('students')
          .select()
          .eq('id', _userId)
          .maybeSingle();

      if (data == null) {
        throw Exception('Profile not found');
      }

      if (!mounted) return;

      setState(() {
        _fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}';
        _institution = data['institution'] ?? '';
        _matricule = data['matricule'] ?? '';

        _selectedLevel = _levels.contains(data['level'])
            ? data['level']
            : _levels.first;

        _selectedMajor = _majors.contains(data['major'])
            ? data['major']
            : _majors.first;

        _selectedSemester = _semesters.contains(data['semester'])
            ? data['semester']
            : _semesters.first;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  // ─────────────────────────────
  // SAVE PROFILE
  // ─────────────────────────────
  Future<void> _saveProfile() async {
    try {
      await _client
          .from('students')
          .update({
            'level': _selectedLevel,
            'major': _selectedMajor,
            'semester': _selectedSemester,
          })
          .eq('id', _userId);

      if (!mounted) return;
      _showMessage('Profile updated successfully');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to save profile', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────
  // UI
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              _profileHeader(),
              const SizedBox(height: 32),

              _sectionTitle('Student Information'),
              _infoTile('Full name', _fullName),
              _infoTile('Institution', _institution),
              _infoTile('Matricule', _matricule),

              const SizedBox(height: 32),

              _sectionTitle('Academic Context'),
              _dropdown(
                label: 'Level',
                value: _selectedLevel,
                items: _levels,
                onChanged: (v) => setState(() => _selectedLevel = v),
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Major',
                value: _selectedMajor,
                items: _majors,
                onChanged: (v) => setState(() => _selectedMajor = v),
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Semester',
                value: _selectedSemester,
                items: _semesters,
                onChanged: (v) => setState(() => _selectedSemester = v),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
  // COMPONENTS
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
            backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.15),
            child: const Icon(Icons.person, size: 32, color: Color(0xFF14B8A6)),
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
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
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
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
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

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : null;

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
          initialValue: safeValue,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
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
