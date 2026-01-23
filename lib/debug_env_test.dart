import 'package:flutter_dotenv/flutter_dotenv.dart';

void testEnv() {
  print("Loaded key: ${dotenv.env['GEMINI_API_KEY']}");
}
