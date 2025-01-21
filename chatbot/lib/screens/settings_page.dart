import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import "../main.dart";
import '../functionality/database.dart';
import '../screens/create_prompt.dart';
import '../screens/manage_prompts_page.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  MyAppState _getAppState(BuildContext context) {
    final state = context.findAncestorStateOfType<MyAppState>();
    if (state == null) {
      throw Exception('MyAppState not found in context');
    }
    return state;
  }

  Future<Map<String, String>> _getSettings() async {
    try {
      return await DatabaseHelper.instance.getSettings();
    } catch (e) {
      return {
        'theme': 'Light',
        'llm_model': 'GPT-4o',
      };
    }
  }

  ThemeMode _getThemeMode(String theme) {
    if (theme == 'Dark') {
      return ThemeMode.dark;
    } else if (theme == 'Light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading settings'));
        } else {
          final settings = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              backgroundColor: Colors.grey[700],
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsDropdownItem(
                  title: 'Theme',
                  options: const ['Light', 'Dark', 'System Default'],
                  selectedOption: settings['theme'] ?? 'Light',
                  onChanged: (String newValue) async {
                    _getAppState(context).changeTheme(_getThemeMode(newValue));
                    await DatabaseHelper.instance.updateSetting('theme', newValue);
                    onThemeChanged(); // Notify the main page to rebuild
                  },
                ),
                const Divider(),
                SettingsDropdownItem(
                  title: 'LLM model',
                  options: const ['GPT-3.5-turbo', 'GPT-4o-mini', 'GPT-4o'],
                  selectedOption: settings['llm_model'] ?? 'GPT-4o',
                  onChanged: (String newValue) async {
                    await DatabaseHelper.instance.updateSetting('llm_model', newValue);
                  },
                ),
                const Divider(),
                SettingsItem(
                  title: 'Create custom chat personality',
                  hasLinkIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePromptPage()),
                    );
                  },
                  trailing: const Icon(Icons.person_add),
                ),
                const Divider(),
                SettingsItem(
                  title: 'Manage custom personalities',
                  hasLinkIcon: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManagePromptsPage()),
                    );
                  },
                  trailing: const Icon(Icons.manage_accounts),
                ),
                const Divider(),
                SettingsItem(
                  title: 'Help',
                  hasLinkIcon: true,
                  onTap: () {
                  },
                ),
                const Divider()
              ],
            ),
            bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
          );
        }
      },
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;

  final bool hasLinkIcon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    this.hasLinkIcon = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (hasLinkIcon
              ? const Icon(Icons.open_in_new)
              : null),
      onTap: onTap,
    );
  }
}

class SettingsDropdownItem extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String>? onChanged;

  const SettingsDropdownItem({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    this.onChanged,
  });

  @override
  _SettingsDropdownItemState createState() => _SettingsDropdownItemState();
}

class _SettingsDropdownItemState extends State<SettingsDropdownItem> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: DropdownButton<String>(
        value: _selectedOption,
        onChanged: (String? newValue) {
          setState(() {
            _selectedOption = newValue!;
          });
          if (widget.onChanged != null) {
            if (newValue != null) {
              widget.onChanged!(newValue);
            }
          }
        },
        items: widget.options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}