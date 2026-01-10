import 'package:supabase_flutter/supabase_flutter.dart';

class PushTriggerService {
  static Future<void> sendPush({
    required String userId,
    required String title,
    required String body,
  }) async {
    final client = Supabase.instance.client;

    // 1️⃣ Get user's FCM token
    final tokenRes = await client
        .from('device_tokens')
        .select('fcm_token')
        .eq('user_id', userId)
        .maybeSingle();

    if (tokenRes == null) return;

    final token = tokenRes['fcm_token'];

    // 2️⃣ Call Edge Function
    await client.functions.invoke(
      'send-push',
      body: {
        'fcm_token': token,
        'title': title,
        'body': body,
      },
    );
  }
}
