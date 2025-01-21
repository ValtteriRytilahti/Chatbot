import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../functionality/database.dart';
import 'main_page.dart';
import 'settings_page.dart';

class HistoryPage extends StatefulWidget {
  final ThemeMode themeMode;

  const HistoryPage({super.key, required this.themeMode});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _loadConversations();
  }

  Future<List<Map<String, dynamic>>> _loadConversations() async {
    return await DatabaseHelper.instance.getConversations();
  }

  Future<void> _deleteConversation(int conversationId) async {
    await DatabaseHelper.instance.deleteConversation(conversationId);
    setState(() {
      _conversationsFuture = _loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: const Text('Chat history'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    onThemeChanged: () {
                      setState(() {}); // Rebuild the page when the theme changes
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading conversations'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No conversations found'));
          } else {
            final conversations = snapshot.data!;
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final title = conversation['title'] as String;
                return ListTile(
                  title: Text(title),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      await _deleteConversation(conversation['id'] as int);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          conversation: conversation,
                          themeMode: widget.themeMode,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}
