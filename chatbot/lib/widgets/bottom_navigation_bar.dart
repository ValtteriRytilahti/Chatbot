import 'package:flutter/material.dart';
import '../screens/history_page.dart';
import '../screens/main_page.dart';
import '../screens/profile_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(themeMode: themeMode)),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HistoryPage(themeMode: themeMode)),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(themeMode: themeMode)),
          );
        }
      },
    );
  }
}