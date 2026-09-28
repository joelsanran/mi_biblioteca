import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'users_management_screen.dart';
import 'books_management_screen.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../../theme/app_theme.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    UsersManagementScreen(),
    BooksManagementScreen(),
  ];

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textLight,
        onPressed: _logout,
        child: const Icon(Icons.logout, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Libros'),
        ],
      ),
    );
  }
}
