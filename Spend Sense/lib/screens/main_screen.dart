import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'expenses/expense_screen.dart';
import 'goals/goal_screen.dart';
import 'split/group_screen.dart';
import 'budget/budget_screen.dart';
import 'analytics/chatbot_screen.dart';
import 'analytics/investment_screen.dart';
import 'settings/main_settings_screen.dart';
import 'placeholder_screen.dart';

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
        backgroundColor: const Color(0xFF161616), // Deep dark background
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16),
              color: const Color(0xFF222222),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shree Shukla', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('My Wallet', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDrawerItem(context, 'Get Premium', Icons.arrow_circle_up, Colors.orange),
            _buildDrawerItem(context, 'Bank Sync', Icons.account_balance, Colors.lightBlue),
            _buildDrawerItem(context, 'Imports', Icons.system_update_alt, Colors.blue),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4B6B), // Highlight color for selected
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ListTile(
                  leading: const Icon(Icons.home_outlined, color: Colors.pinkAccent),
                  title: const Text('Home', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
            _buildDrawerItem(context, 'Records', Icons.list, Colors.orangeAccent),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.greenAccent),
              title: const Text('Investments', style: TextStyle(color: Colors.white, fontSize: 18)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen()));
              },
            ),
            _buildDrawerItem(context, 'Statistics', Icons.show_chart, Colors.cyan),
            _buildDrawerItem(context, 'Planned payments', Icons.update, Colors.orange),
            _buildDrawerItem(context, 'Budgets', Icons.money, Colors.red, screen: const BudgetScreen()),
            _buildDrawerItem(context, 'Debts', Icons.money_off, Colors.redAccent),
            _buildDrawerItem(context, 'Goals', Icons.flag_outlined, Colors.cyanAccent, screen: const GoalScreen()),
            _buildDrawerItem(context, 'Shopping lists', Icons.shopping_basket_outlined, Colors.green),
            _buildDrawerItem(context, 'Warranties', Icons.verified_user_outlined, Colors.orange),
            _buildDrawerItem(context, 'Loyalty cards', Icons.card_giftcard, Colors.redAccent),
            _buildDrawerItem(context, 'Currency rates', Icons.currency_exchange, Colors.lightBlueAccent),
            _buildDrawerItem(context, 'Group sharing', Icons.group_outlined, Colors.teal, screen: const GroupScreen()),
            
            ExpansionTile(
              leading: const Icon(Icons.more_horiz, color: Colors.grey),
              title: const Text('Others', style: TextStyle(color: Colors.white, fontSize: 18)),
              iconColor: Colors.cyan,
              collapsedIconColor: Colors.cyan,
              children: [
                SwitchListTile(
                  title: const Text('Dark mode', style: TextStyle(color: Colors.white, fontSize: 18)),
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: Colors.blueAccent,
                ),
                SwitchListTile(
                  title: const Text('Hide Amounts', style: TextStyle(color: Colors.white, fontSize: 18)),
                  value: false,
                  onChanged: (val) {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDrawerItem(context, 'Invite friends', Icons.person_add_alt_1, Colors.lightBlue),
            _buildDrawerItem(context, 'Follow us', Icons.favorite_border, Colors.pinkAccent),
            _buildDrawerItem(context, 'Help', Icons.help_outline, Colors.orange),
            _buildDrawerItem(context, 'Settings', Icons.tune, Colors.greenAccent, screen: const MainSettingsScreen()),
            const SizedBox(height: 30),
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

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Color color, {Widget? screen}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen ?? PlaceholderScreen(title: title)));
      },
    );
  }
}
