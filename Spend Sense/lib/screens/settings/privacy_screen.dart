import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _emailEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailEnabled = prefs.getBool('privacy_email') ?? true;
    });
  }

  void _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showDeleteDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to perform this action? This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Personal data & Privacy', style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('DOCUMENTS TO REVIEW'),
            ListTile(
              leading: const Icon(Icons.shield, color: Colors.blueAccent),
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {},
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blueAccent),
              title: const Text('Terms of Services', style: TextStyle(color: Colors.white, fontSize: 18)),
              onTap: () {},
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('EMAILS & MESSAGES SETTINGS'),
            SwitchListTile(
              activeThumbColor: Colors.black,
              activeTrackColor: Colors.blueAccent,
              inactiveTrackColor: Colors.white24,
              title: const Text('Email and messages', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              value: _emailEnabled,
              onChanged: (val) {
                setState(() => _emailEnabled = val);
                _saveSetting('privacy_email', val);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'You can turn off all promotional and commercial content using the button above. This will not affect service messages like password change alerts.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('DATA PORTABILITY'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'You have right to change your personal data by editing your profile information, change your transaction data for cash accounts by editing them. You can delete your transactions from linked account by deleting the whole set of transaction - those data are not editable.\n\nYou have right to be informed about the data we hold about you and you can transfer your data and you have right to be forgotten and delete all your data - all of which you can do by sending us an email to support@spend-sense.com. In case you have any specific issues or request, please contact our Data Protection Officer on email: dpo@spend-sense.com',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A1111),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDeleteDialog('Delete all user data'),
                child: const Text('Delete all user data', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDeleteDialog('Delete Profile and all data'),
                child: const Text('Delete Profile and all data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}
