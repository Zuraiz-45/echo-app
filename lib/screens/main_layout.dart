import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import '../widgets/user_posts_list.dart';
import '../services/auth_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Build screens inside build() so they use the correct theme context
    final screens = <Widget>[
      const HomeScreen(),
      const MessagesScreen(),
      _buildMyPostsScreen(context),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                context.theme.brightness == Brightness.dark ? 0.2 : 0.05,
              ),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.theme.colorScheme.surface,
          selectedItemColor: context.theme.colorScheme.primary,
          unselectedItemColor: context.theme.textTheme.bodyMedium?.color,
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

  Widget _buildMyPostsScreen(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.currentUser.value;
      if (user == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'My Posts',
            style: TextStyle(
              color: context.theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: UserPostsList(userId: user.id),
        ),
      );
    });
  }
}
