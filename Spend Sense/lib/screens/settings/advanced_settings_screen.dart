import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _useDecimals = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useDecimals = prefs.getBool('adv_use_decimals') ?? true;
    });
  }

  void _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Advanced settings', style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          SwitchListTile(
            activeThumbColor: Colors.black,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white24,
            title: const Text('Number format', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text('Use decimals within amounts.', style: TextStyle(color: Colors.white54)),
            value: _useDecimals,
            onChanged: (val) {
              setState(() => _useDecimals = val);
              _saveSetting('adv_use_decimals', val);
            },
          ),
          ListTile(
            title: const Text('Active module after launch', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text('Dashboard module', style: TextStyle(color: Colors.white54)),
            trailing: Switch(
              value: false,
              onChanged: null,
              activeThumbColor: Colors.black,
              activeTrackColor: Colors.blueAccent,
              inactiveTrackColor: Colors.white24,
            ),
          ),
          const ListTile(
            title: Text('Initial day of the month', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('Beginning of the accounting period: 1', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
