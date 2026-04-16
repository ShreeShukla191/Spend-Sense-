import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'expenses/expense_screen.dart';
import 'goals/goal_screen.dart';
import 'split/group_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExpenseScreen(),
    const GoalScreen(),
    const GroupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Split'),
        ],
      ),
    );
  }
}
