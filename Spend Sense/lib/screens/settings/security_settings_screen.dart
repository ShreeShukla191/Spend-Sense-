import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _pinEnabled = false;
  bool _fingerprintEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getBool('security_pin') ?? false;
      _fingerprintEnabled = prefs.getBool('security_fingerprint') ?? true;
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
        title: const Text('Security', style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          SwitchListTile(
            activeThumbColor: Colors.black,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white24,
            secondary: const Icon(Icons.lock, color: Colors.blueAccent),
            title: const Text('PIN', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text('Require PIN on startup', style: TextStyle(color: Colors.white54)),
            value: _pinEnabled,
            onChanged: (val) {
              setState(() => _pinEnabled = val);
              _saveSetting('security_pin', val);
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            activeThumbColor: Colors.black,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white24,
            secondary: const Icon(Icons.fingerprint, color: Colors.blueAccent),
            title: const Text('Fingerprint', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: const Text('Require Fingerprint on startup', style: TextStyle(color: Colors.white54)),
            value: _fingerprintEnabled,
            onChanged: (val) {
              setState(() => _fingerprintEnabled = val);
              _saveSetting('security_fingerprint', val);
            },
          ),
        ],
      ),
    );
  }
}
