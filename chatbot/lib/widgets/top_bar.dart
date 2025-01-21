import 'package:flutter/material.dart';
import '../screens/settings_page.dart';
import '../functionality/database.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeChanged;
  final DatabaseHelper dbHelper;
  final Function(int) onNewConversation;

  const TopBar({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.dbHelper,
    required this.onNewConversation,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeMode == ThemeMode.dark;
    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage(onThemeChanged: onThemeChanged)),
          );
          onThemeChanged();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () async {
            int conversationId = await dbHelper.createConversation('New Conversation');
            onNewConversation(conversationId);
          },
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
