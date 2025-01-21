import 'package:flutter/material.dart';
import '../functionality/database.dart';

class ManagePromptsPage extends StatefulWidget {

  @override
  _ManagePromptsPageState createState() => _ManagePromptsPageState();
}

class _ManagePromptsPageState extends State<ManagePromptsPage> {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _refreshPrompts() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Custom Personalities'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getPrompts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading prompts'));
          } else {
            final prompts = snapshot.data!;
            return ListView.builder(
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return ListTile(
                  title: Text(prompt['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _dbHelper.deletePrompt(prompt['id']);
                      await _refreshPrompts();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}