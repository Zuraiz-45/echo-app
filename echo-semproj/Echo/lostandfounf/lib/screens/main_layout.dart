import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import '../theme/colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MessagesScreen(),
    const Center(child: Text('My Posts Screen')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_filled)), label: 'Home'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.chat_bubble)), label: 'Messages'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.layers)), label: 'My Posts'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person)), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
