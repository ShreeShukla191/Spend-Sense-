import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'expenses/expense_screen.dart';
import 'goals/goal_screen.dart';
import 'split/group_screen.dart';
import 'analytics/chatbot_screen.dart';
import 'expenses/subscription_screen.dart';
import 'expenses/account_screen.dart';
import 'analytics/analytics_screen.dart';
import 'analytics/learning_hub_screen.dart';
import 'analytics/records_screen.dart';
import 'analytics/investment_screen.dart';
import 'analytics/statistics_screen.dart';

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
    const ChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('SpendSense\nFeatures', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions, color: Colors.indigo),
              title: const Text('Subscriptions'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.teal),
              title: const Text('Bank Accounts'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blueAccent),
              title: const Text('Analytics & Exports'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Investments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.orangeAccent),
              title: const Text('Financial Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.deepPurple),
              title: const Text('Learning Hub'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningHubScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books, color: Colors.orange),
              title: const Text('Master Records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordsScreen()));
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Split'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI Chat'),
        ],
      ),
    );
  }
}
