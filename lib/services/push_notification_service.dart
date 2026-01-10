import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  PushNotificationService._();

  static final _fcm = FirebaseMessaging.instance;

  /// 🔐 Request permission (Android 13+ / iOS)
  static Future<void> requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// 📱 Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _fcm.getToken();
      if (kDebugMode) {
        print('📱 FCM Token: $token');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// 💾 Save token to Supabase
  static Future<void> saveTokenToSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint('⚠️ No user logged in, skipping token save');
      return;
    }

    final token = await getToken();
    if (token == null) return;

    await Supabase.instance.client
        .from('device_tokens')
        .upsert({
          'user_id': user.id, // ✅ auth.uid()
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'updated_at': DateTime.now().toIso8601String(),
        });

    debugPrint('✅ FCM token saved to Supabase');
  }

  /// 🚀 Call once after login
  static Future<void> initAfterLogin() async {
    await requestPermission();
    await saveTokenToSupabase();
  }
}
