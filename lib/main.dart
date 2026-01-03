import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/selected_day.dart';
import 'state/daily_progress.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Load environment variables
  await dotenv.load(fileName: ".env");

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || key == null) {
    throw Exception(
      "Supabase URL or ANON KEY is missing from .env",
    );
  }

  //  Initialize Supabase
  await Supabase.initialize(
    url: url,
    anonKey: key,
  );

  //  Run app with global providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SelectedDay(),
        ),
        ChangeNotifierProvider(
          create: (_) => DailyProgress(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
