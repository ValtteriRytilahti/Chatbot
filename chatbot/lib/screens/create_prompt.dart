import 'package:flutter/material.dart';
import '../functionality/database.dart';

class CreatePromptPage extends StatelessWidget {
  CreatePromptPage({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Personality name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Prompt Content',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _dbHelper.insertPrompt(
                      _nameController.text,
                      _contentController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
