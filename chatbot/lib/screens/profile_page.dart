import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../functionality/database.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(themeMode: ThemeMode.light),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final ThemeMode themeMode;

  const ProfilePage({super.key, required this.themeMode});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImagePath;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadName();
  }

  Future<void> _loadProfileImage() async {
    final settings = await DatabaseHelper.instance.getSettings();
    setState(() {
      _profileImagePath = settings['profile_image'];
    });
  }

  Future<void> _loadName() async {
    final settings = await DatabaseHelper.instance.getSettings();
    setState(() {
      _nameController.text = settings['name'] ?? 'Jon Smith';
    });
  }

  Future<void> _saveName() async {
    await DatabaseHelper.instance.updateSetting('name', _nameController.text);
  }

  Future<void> _uploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        await DatabaseHelper.instance.updateSetting('profile_image', pickedFile.path);
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {

      print('Error uploading photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload photo. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[800],
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
              child: _profileImagePath == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              onSubmitted: (_) => _saveName(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPhoto,
              child: const Text('Upload a photo'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
