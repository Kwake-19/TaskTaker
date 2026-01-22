import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tasktaker/services/ai_service.dart';
import 'package:tasktaker/services/pdf_service.dart';




class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  String status = '👋 Ready to test the AI feature!';
  bool isLoading = false;

  // Test the complete flow: PDF → Extract → AI
  Future<void> testFullFlow() async {
    setState(() {
      isLoading = true;
      status = '🔍 Step 1: Testing API connection...';
    });

    // ✅ Test 1: API connection
    final bool apiWorks = await AIService.testConnection();

    if (!apiWorks) {
      setState(() {
        status =
            '❌ API connection failed!\n\nCheck:\n'
            '1. GEMINI_API_KEY in Supabase secrets\n'
            '2. Edge Function deployed\n'
            '3. Internet connection';
        isLoading = false;
      });
      return;
    }

    setState(() {
      status = '✅ API works!\n\n📁 Step 2: Please select a PDF file...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // ✅ Test 2: Pick PDF
    final File? pdfFile = await PDFService.pickPDF();

    if (pdfFile == null) {
      setState(() {
        status = '⚠️ No PDF selected. Test cancelled.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      status = '✅ PDF selected!\n\n📖 Step 3: Extracting text...';
    });

    try {
      // ✅ Test 3: Extract text
      final String text = await PDFService.extractTextFromPDF(pdfFile);

      if (text.isEmpty) {
        throw Exception('PDF contains no readable text.');
      }

      final previewLength = text.length < 100 ? text.length : 100;

      setState(() {
        status =
            '✅ Extracted ${text.length} characters!\n\n'
            'First 100 chars:\n'
            '"${text.substring(0, previewLength)}..."\n\n'
            '🤖 Step 4: Sending to AI...';
      });

      await Future.delayed(const Duration(seconds: 2));

      // ✅ Test 4: AI generation
      final List<Map<String, dynamic>> quiz =
          await AIService.generateQuiz(text);

      if (quiz.isEmpty) {
        throw Exception('AI returned no questions.');
      }

      setState(() {
        status =
            '🎉 SUCCESS!\n\n'
            'Generated ${quiz.length} questions!\n\n'
            '📝 First question:\n'
            '${quiz[0]['question']}\n\n'
            'A) ${quiz[0]['options'][0]}\n'
            'B) ${quiz[0]['options'][1]}\n'
            'C) ${quiz[0]['options'][2]}\n'
            'D) ${quiz[0]['options'][3]}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = '❌ Error:\n$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Feature Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (isLoading)
              Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Please wait...',
                      style: TextStyle(color: Colors.grey)),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: testFullFlow,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
