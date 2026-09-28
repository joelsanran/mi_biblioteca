import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import '../../theme/app_theme.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  final String userId;
  final String userName;
  final String userEmail;

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(userName: widget.userName, userId: widget.userId),
      SearchScreen(userId: widget.userId),
      LibraryScreen(userId: widget.userId),
      ProfileScreen(name: widget.userName, email: widget.userEmail),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Mi biblioteca',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
