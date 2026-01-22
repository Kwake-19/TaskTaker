import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Service for interacting with Google Gemini AI
class AIService {
  // Gemini API endpoint
  static const String _baseUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Get API key from .env file
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    return key;
  }
  
  // Generate quiz questions from document text
  static Future<List<Map<String, dynamic>>> generateQuiz(String documentText) async {
    try {
      print('📤 Sending text to Gemini AI...');
      
      // Create the prompt for AI
      final prompt = '''
You are a study assistant. Based on the following text, generate exactly 5 multiple-choice questions to test understanding.

For each question, provide:
- A clear question
- 4 answer options
- The correct answer index (0-3)

Format your response as a JSON array like this:
[
  {
    "question": "What is photosynthesis?",
    "options": ["Process A", "Process B", "Process C", "Process D"],
    "correctAnswer": 1
  }
]

IMPORTANT: 
- correctAnswer should be the INDEX (0, 1, 2, or 3) of the correct option
- Return ONLY the JSON array, no other text or markdown
- Make questions test actual understanding

Text to analyze:
$documentText
''';
      
      // Make API request to Gemini
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,  // Creativity level (0.0 - 1.0)
            'maxOutputTokens': 2048,  // Max response length
          }
        }),
      );
      
      // Check if request was successful
      if (response.statusCode == 200) {
        print('✅ Got response from Gemini!');
        
        // Parse the response
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        print('🤖 AI Response preview: ${aiResponse.substring(0, 100)}...');
        
        // Clean up response (remove markdown if present)
        String cleanResponse = aiResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        // Parse JSON array
        final quizData = jsonDecode(cleanResponse) as List;
        
        print('✅ Generated ${quizData.length} questions');
        return quizData.cast<Map<String, dynamic>>();
        
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to generate quiz: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error in generateQuiz: $e');
      rethrow;
    }
  }
  
  // Test if API connection works
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing Gemini API connection...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello, respond with just "API Working"'}
              ]
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ API connection successful!');
        return true;
      } else {
        print('❌ API connection failed: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('❌ Connection test error: $e');
      return false;
    }
  }
}