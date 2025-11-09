import 'package:flutter/material.dart';
import 'browse_listings_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';
import '../main.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  // List of all the main screens
  final List<Widget> _screens = const [
    BrowseListingsScreen(),
    MyListingsScreen(),
    ChatsScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use IndexedStack to keep the state of each screen
      // when switching tabs.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      backgroundColor: MyApp.backgroundWhite,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: MyApp.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: MyApp.primaryBlue,
          unselectedItemColor: MyApp.secondaryText,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          iconSize: 26,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined, size: 24),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyApp.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search_rounded, size: 24),
              ),
              label: "Browse",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined, size: 24),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyApp.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded, size: 24),
              ),
              label: "My Listings",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline, size: 24),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyApp.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_rounded, size: 24),
              ),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined, size: 24),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyApp.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_rounded, size: 24),
              ),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}