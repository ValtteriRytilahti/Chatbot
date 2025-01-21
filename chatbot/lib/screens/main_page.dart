// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import "../functionality/gpt_api.dart";
import '../functionality/database.dart';
import '../widgets/top_bar.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic>? conversation;
  final ThemeMode themeMode;

  const MainPage({super.key, this.conversation, required this.themeMode});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  String _selectedPersonality = 'Chatbot personality name';
  int? _conversationId;
  List<Map<String, String>> _prompts = [];

  final gpt_api = GptApi(); 
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _loadPrompts();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadConversation() async {
    if (_conversationId != null) {
      return;
    }
    if (widget.conversation != null) {
      _conversationId = widget.conversation!['id'] as int;
      final messages = await _dbHelper.getMessages(_conversationId!);
      setState(() {
        _messages = messages.map((msg) => {
          "type": msg['type'] as String,
          "text": msg['text'] as String,
        }).toList();
      });
    } else {
      // Check if there are any existing conversations
      final conversations = await _dbHelper.getConversations();
      if (conversations.isNotEmpty) {
        _conversationId = conversations.last['id'] as int;
        final messages = await _dbHelper.getMessages(_conversationId!);
        setState(() {
          _messages = messages.map((msg) => {
            "type": msg['type'] as String,
            "text": msg['text'] as String,
          }).toList();
        });
      } else {
        _conversationId = await _dbHelper.createConversation('New Conversation');
        setState(() {
          _messages = [];
        });
      }
    }
  }

  Future<void> _loadPrompts() async {
    final prompts = await _dbHelper.getPrompts();
    setState(() {
      _prompts = [
        {"name": "Chatbot personality name", "content": "Chatbot personality name"},
        ...prompts.map((prompt) => {
          "name": prompt['name'] as String,
          "content": prompt['content'] as String,
        })
      ];
    });
  }

  Future<void> _sendMessage(String text, String personality) async {
    setState(() {
      _messages.add({"type": "sent", "text": text});
    });
    await _dbHelper.insertMessage(_conversationId!, "sent", text);

    // Update conversation title with the first 10 characters of the first message
    if (_messages.length == 1) {
      String newTitle = text.length > 10 ? text.substring(0, 10) : text;
      await _dbHelper.updateConversationTitle(_conversationId!, newTitle);
    }

    // Get model from database
    final settings = await _dbHelper.getSettings();
    String? model = settings['llm_model'] ?? 'None';
    
    String response = await gpt_api.queryGpt(text, personality, _messages.take(5).toList(), model);
    setState(() {
      _messages.add({"type": "received", "text": response});
    });
    await _dbHelper.insertMessage(_conversationId!, "received", response);
  }

  void _rebuildPage() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: TopBar(
        themeMode: widget.themeMode,
        onThemeChanged: _rebuildPage,
        dbHelper: _dbHelper,
        onNewConversation: (int conversationId) {
          setState(() {
            _conversationId = conversationId;
            _messages = [];
          });
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: isDarkMode ? Colors.black : Colors.grey[200],
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: _messages.map((message) {
                  return Align(
                    alignment: message["type"] == "sent"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: message["type"] == "sent"
                            ? (isDarkMode ? Colors.blueGrey[700] : Colors.grey[300])
                            : (isDarkMode ? Colors.blueGrey[800] : Colors.grey[400]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message["text"]!,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'Roboto'
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    filled: true,
                  ),
                  value: _selectedPersonality,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPersonality = newValue!;
                    });
                  },
                  items: _prompts.map<DropdownMenuItem<String>>((prompt) {
                    return DropdownMenuItem<String>(
                      value: prompt['content'],
                      child: Text(prompt['name']!),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type something...',
                          border: const OutlineInputBorder(),
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                          filled: true,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: isDarkMode ? Colors.white : Colors.black,
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text, _selectedPersonality);
                          _controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}