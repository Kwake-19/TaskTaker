import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/selected_day.dart';
import 'state/daily_progress.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

/// 🔔 Background message handler
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 🔥 Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Background FCM handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // 🔔 Notification permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 🔔 Local notifications
  await NotificationService.init();

  // 🧠 Supabase init
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ⭐ LISTEN FOR PASSWORD RESET EVENTS
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    if (event.event == AuthChangeEvent.passwordRecovery) {
      // AUTOMATICALLY SEND USER TO RESET PASSWORD SCREEN
      rootNavigatorKey.currentState?.pushNamed("/reset-password");
    }
  });

  // ⭐ Load SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final remember = prefs.getBool("remember_me") ?? false;

  // ⭐ Load existing Supabase session
  final session = Supabase.instance.client.auth.currentSession;

  // ⭐ Decide which page to load first
  String initialRoute;
  if (remember && session != null) {
    initialRoute = "/home";
  } else {
    initialRoute = "/login";
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedDay()),
        ChangeNotifierProvider(create: (_) => DailyProgress()),
      ],
      child: MyApp(
        navigatorKey: rootNavigatorKey,
        initialRoute: initialRoute, // ⭐ important
      ),
    ),
  );
}
