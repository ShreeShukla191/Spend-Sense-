import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _toggles = {
    'Wallet reminder': true,
    'Accounts': true,
    'Unconfirmed records': true,
    'Budgets': true,
    'Planned payments': true,
    'Debts': true,
    'Imports': true,
    'New blog posts': true,
    'Income': true,
  };

  final Map<String, String> _subtitles = {
    'Wallet reminder': 'Fires notification at 20:00 to remind you to write down your expenses for the day.',
    'Accounts': 'Informs about account limit exceeding',
    'Unconfirmed records': 'Reminds you about your unconfirmed records.',
    'Budgets': 'Reminds and controls overspending in your budget',
    'Planned payments': 'Reminds about upcoming planned payments',
    'Debts': 'Reminds about upcoming debt due dates',
    'Imports': 'When import from CSV file received',
    'New blog posts': 'Informs about new Wallet blog posts with financial tips.',
    'Income': 'Informs about a significant income on your accounts',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String key in _toggles.keys) {
        _toggles[key] = prefs.getBool('notif_$key') ?? true;
      }
    });
  }

  void _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$key', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: _toggles.keys.map((key) {
          return Column(
            children: [
              SwitchListTile(
                activeThumbColor: Colors.black,
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.white24,
                title: Text(key, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(_subtitles[key]!, style: const TextStyle(color: Colors.white54)),
                value: _toggles[key]!,
                onChanged: (val) {
                  setState(() => _toggles[key] = val);
                  _saveSetting(key, val);
                },
              ),
              const Divider(color: Colors.white12, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}
