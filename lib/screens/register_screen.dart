import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🔹 Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();

  final AuthService _authService = AuthService();

  // 🔹 Dropdown options
  final List<String> _levels = ['100', '200', '300', '400'];
  final List<String> _majors = [
    'Computer Science',
    'Software Engineering',
    'Information Systems',
    'Cyber Security',
    'Data Science',
  ];
  final List<String> _semesters = ['Fall', 'Spring'];

  // 🔹 Selected values
  String _selectedInstitution = "ICT University";
  String _selectedLevel = '100';
  String _selectedMajor = 'Computer Science';
  String _selectedSemester = 'Fall';

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

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final matricule = _matriculeController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        matricule.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerStudent(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        institution: _selectedInstitution,
        matricule: matricule,
        level: _selectedLevel,
        major: _selectedMajor,
        semester: _selectedSemester,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showError(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ListView(
            children: [
              const SizedBox(height: 40),

              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),

              const Text(
                "Create an account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 30),

              // 👤 NAME
              _input(_firstNameController, "First Name", "e.g Arabella"),
              _input(_lastNameController, "Last Name", "e.g Kwake"),

              // 🏫 ACADEMIC INFO
              _dropdown("Institution", _selectedInstitution,
                  const ["ICT University"],
                  (v) => setState(() => _selectedInstitution = v!)),

              _dropdown("Level", _selectedLevel, _levels,
                  (v) => setState(() => _selectedLevel = v!)),

              _dropdown("Major", _selectedMajor, _majors,
                  (v) => setState(() => _selectedMajor = v!)),

              _dropdown("Semester", _selectedSemester, _semesters,
                  (v) => setState(() => _selectedSemester = v!)),

              // 🆔 AUTH INFO
              _input(_matriculeController, "Matricule", "e.g ICTU20241518"),
              _input(_emailController, "Email",
                  "student@ictuniversity.org",
                  type: TextInputType.emailAddress),
              _input(_passwordController, "Password", "At least 6 characters",
                  obscure: true),
              _input(_confirmPasswordController, "Confirm Password",
                  "Re-enter password",
                  obscure: true),

              const SizedBox(height: 30),

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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Account",
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
  // 🔽 HELPERS
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
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
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
    String label,
    String hint, {
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
              hintText: hint,
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
