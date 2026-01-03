import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  // ─────────────────────────────
  // Controllers
  // ─────────────────────────────
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _matriculeController = TextEditingController();


  final AuthService _authService = AuthService();


  // ─────────────────────────────
  // Dropdown data
  // ─────────────────────────────
  final List<String> _levels = ['100', '200', '300', '400'];


  /// 🔑 MAJOR CODE → DISPLAY NAME
  final Map<String, String> _majors = {
    'CS': 'Computer Science',
    'SEN': 'Software Engineering',
    'ISN': 'Information Systems & Networking',
    'CYS': 'Cyber Security',
    'ICT': 'Information and Communication Technology',
  };


  final List<String> _semesters = ['Fall', 'Spring'];


  String _institution = 'ICT University';
  String _level = '100';
  String _majorCode = 'CS'; // ✅ STORE CODE, NOT NAME
  String _semester = 'Fall';


  bool _isLoading = false;


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }


  // ─────────────────────────────
  // REGISTER LOGIC
  // ─────────────────────────────
  Future<void> _register() async {
    if (_isLoading) return;


    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final matricule = _matriculeController.text.trim();


    if ([
      firstName,
      lastName,
      email,
      password,
      confirmPassword,
      matricule
    ].any((e) => e.isEmpty)) {
      _showError('Please fill in all fields.');
      return;
    }


    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }


    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }


    setState(() => _isLoading = true);


    try {
      await _authService.registerStudent(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        institution: _institution,
        matricule: matricule,
        level: _level,
        major: _majorCode, // ✅ CODE GOES TO DATABASE
        semester: _semester,
      );


      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError(
        e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  // ─────────────────────────────
  // UI
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ListView(
            children: [
              const SizedBox(height: 24),


              IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),


              const SizedBox(height: 16),


              const Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),


              const SizedBox(height: 28),


              _input(_firstNameController, 'First Name'),
              _input(_lastNameController, 'Last Name'),


              _dropdown(
                'Institution',
                _institution,
                const ['ICT University'],
                (v) => setState(() => _institution = v!),
              ),


              _dropdown(
                'Level',
                _level,
                _levels,
                (v) => setState(() => _level = v!),
              ),


              /// 🎓 MAJOR (CODE ↔ NAME)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Major',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _majorCode,
                      items: _majors.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,          // SEN, CSC
                              child: Text(e.value),  // Display name
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _majorCode = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              _dropdown(
                'Semester',
                _semester,
                _semesters,
                (v) => setState(() => _semester = v!),
              ),


              _input(_matriculeController, 'Matricule'),
              _input(_emailController, 'Email',
                  type: TextInputType.emailAddress),
              _input(_passwordController, 'Password', obscure: true),
              _input(_confirmPasswordController, 'Confirm Password',
                  obscure: true),


              const SizedBox(height: 28),


              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18),
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
  // HELPERS
  // ─────────────────────────────
  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _input(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}







