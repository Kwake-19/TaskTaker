import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class StudyBuddyTab extends StatefulWidget {
  const StudyBuddyTab({super.key});

  @override
  State<StudyBuddyTab> createState() => _StudyBuddyTabState();
}

class _StudyBuddyTabState extends State<StudyBuddyTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hi 👋 I'm your Study Buddy.\nUpload a PDF or ask me anything to revise!",
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto scroll to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 📎 Pick PDF + Extract text + Send to AI
  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final pdfFile = File(result.files.single.path!);

      setState(() {
        _messages.add(_ChatMessage(
          text: "📄 PDF selected: ${result.files.single.name}\nExtracting text...",
          isUser: false,
        ));
      });
      _scrollToBottom();

      // Extract text from PDF
      final extractedText = await _extractTextFromPDF(pdfFile);

      setState(() {
        _messages.add(_ChatMessage(
          text: "📘 Notes extracted. Sending to AI...\n(This may take a moment)",
          isUser: false,
        ));
      });
      _scrollToBottom();

      await _sendToAI(extractedText);

    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: "❌ Error picking PDF: $e", isUser: false));
      });
    }
  }

  /// Extract text from PDF using Syncfusion
  Future<String> _extractTextFromPDF(File file) async {
    final bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    final extractor = PdfTextExtractor(document);
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < document.pages.count; i++) {
      final text = extractor.extractText(startPageIndex: i);
      buffer.writeln(text);
      buffer.writeln();
    }

    document.dispose();

    String fullText = buffer.toString().trim();

    // Limit text length for AI
    if (fullText.length > 15000) {
      fullText = fullText.substring(0, 15000);
    }

    return fullText;
  }

  /// Send text to Supabase AI Function
  Future<void> _sendToAI(String content) async {
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;

      final response = await client.functions.invoke(
        "ai_quiz",
        body: {"content": content},
      );

      final String aiReply = response.data["quiz"] ?? "No response from AI.";

      setState(() {
        _messages.add(_ChatMessage(text: aiReply, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();

    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: "⚠️ Error contacting AI: $e",
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  /// Send normal user message
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    _controller.clear();
    _scrollToBottom();

    await _sendToAI(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Study Buddy",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          /// Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Study Buddy is thinking...",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// PDF Upload Button
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: const Color(0xFF0F172A),
            onPressed: _pickPDF,
          ),

          /// Text input
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Ask Study Buddy...",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          /// Send button
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF14B8A6),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// CHAT BUBBLE WIDGET
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CHAT MESSAGE MODEL
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
