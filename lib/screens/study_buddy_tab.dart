import 'package:flutter/material.dart';

class StudyBuddyTab extends StatefulWidget {
  const StudyBuddyTab({super.key});

  @override
  State<StudyBuddyTab> createState() => _StudyBuddyTabState();
}

class _StudyBuddyTabState extends State<StudyBuddyTab> {
  final TextEditingController _controller = TextEditingController();

  /// 🧪 DUMMY CHAT MESSAGES (UI ONLY)
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hi 👋 I'm your Study Buddy.\nUpload your notes or ask me to help you revise.",
      isUser: false,
    ),
    _ChatMessage(
      text: "Help me revise Computer Networks",
      isUser: true,
    ),
    _ChatMessage(
      text:
          "Sure! Here are some revision questions:\n\n1. What is the OSI model?\n2. Difference between TCP and UDP?\n3. What is packet switching?",
      isUser: false,
    ),
  ];

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
          /// 💬 CHAT MESSAGES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          /// ✍️ INPUT BAR
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 📎 UPLOAD NOTES
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: const Color(0xFF0F172A),
            onPressed: () {
              // UI ONLY
            },
          ),

          /// 📝 TEXT INPUT
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Ask Study Buddy...",
                border: InputBorder.none,
              ),
            ),
          ),

          /// 🚀 SEND
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF14B8A6),
            onPressed: () {
              if (_controller.text.trim().isEmpty) return;

              setState(() {
                _messages.add(
                  _ChatMessage(
                    text: _controller.text.trim(),
                    isUser: true,
                  ),
                );
              });

              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}

/// 💬 CHAT BUBBLE
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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

/// 🧠 CHAT MESSAGE MODEL (UI ONLY)
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
