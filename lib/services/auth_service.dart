import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/matricule_validator.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🧾 REGISTER STUDENT
  Future<void> registerStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String institution,
    required String matricule,
    required String level,
    required String major,
    required String semester,
  }) async {
    // 🔹 Extract admission year from matricule
    final admissionYear =
        ICTUMatriculeValidator.extractAdmissionYear(matricule);

    // 🔹 Create auth user
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception("Registration failed.");
    }

    // 🔹 Save student profile
    await _client.from('students').insert({
      'id': user.id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'institution': institution,
      'matricule': matricule,
      'admission_year': admissionYear,
      'level': level,
      'major': major,
      'semester': semester,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 🔐 LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception("Invalid email or password.");
    }
  }

  /// 👤 CURRENT USER
  User? get currentUser => _client.auth.currentUser;
}
