import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 🔥 NEW: Remember Me + Password visibility
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  /// Load remember me saved state
  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("remember_me") ?? false;

    if (saved) {
      _rememberMe = true;

      // Load saved email if you want (optional)
      // _emailController.text = prefs.getString("saved_email") ?? "";
    }

    setState(() {});
  }

  /// Save Remember Me selection
  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("remember_me", _rememberMe);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(email: email, password: password);

      await _saveRememberMe();

      // INIT PUSH NOTIFICATIONS AFTER LOGIN
      await PushNotificationService.initAfterLogin();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showError(
        e.toString().replaceAll("Exception:", "").trim(),
      );
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            28,
            0,
            28,
            keyboardInset + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              /// 🔙 BACK
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFF0F172A),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 32),

              /// 🔐 HEADER
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Log in to continue managing your academic life.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 40),

              _InputField(
                controller: _emailController,
                label: "Email address",
                hint: "student@school.edu",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              /// 🔥 UPDATED PASSWORD FIELD WITH EYE ICON
              _InputField(
                controller: _passwordController,
                label: "Password",
                hint: "••••••••",
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              /// 🔥 REMEMBER ME + FORGOT PASSWORD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) {
                          setState(() => _rememberMe = v ?? false);
                        },
                      ),
                      const Text(
                        "Remember me",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/forgot-password");
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14B8A6),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: const Text(
                    "Don’t have an account? Create one",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14B8A6),
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
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon; // 🔥 NEW

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon, // 🔥 NEW
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF14B8A6),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
