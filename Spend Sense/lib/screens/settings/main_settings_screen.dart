import 'package:flutter/material.dart';
import '../placeholder_screen.dart';
import 'user_profile_screen.dart';
import 'security_settings_screen.dart';
import 'advanced_settings_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import '../expenses/account_screen.dart';

class MainSettingsScreen extends StatelessWidget {
  const MainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background matching the screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontSize: 26, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildTopItem(
            context,
            icon: Icons.account_circle,
            iconColor: Colors.blueAccent,
            title: 'User profile',
            subtitle: 'Change profile image, name or password, logout or delete data',
            screen: const UserProfileScreen(),
          ),
          _buildTopItem(
            context,
            icon: Icons.star,
            iconColor: Colors.blueAccent,
            title: 'Premium plans',
            subtitle: 'Explore premium options and enjoy Wallet in its full functionality',
          ),
          _buildSectionHeader('General'),
          _buildSettingItem(
            context,
            icon: Icons.account_balance,
            iconColor: Colors.blueAccent,
            title: 'Accounts',
            subtitle: 'Manage accounts, change icons, color and description',
            screen: const AccountScreen(),
          ),
          _buildSettingItem(
            context,
            icon: Icons.pie_chart,
            iconColor: Colors.blueAccent,
            title: 'Categories',
            subtitle: 'Manage categories, change icons, color and add custom subcategories',
          ),
          _buildSettingItem(
            context,
            icon: Icons.local_offer,
            iconColor: Colors.blueAccent,
            title: 'Labels',
            subtitle: 'Define labels for better filtering',
          ),
          _buildSettingItem(
            context,
            icon: Icons.receipt_long,
            iconColor: Colors.blueAccent,
            title: 'Templates',
            subtitle: 'Create templates to speed up the addition of new records',
          ),
          _buildSettingItem(
            context,
            icon: Icons.tune,
            iconColor: Colors.blueAccent,
            title: 'Filters',
            subtitle: 'Set custom filters that you can use in Statistics or Records',
          ),
          _buildSettingItem(
            context,
            icon: Icons.compare_arrows,
            iconColor: Colors.blueAccent,
            title: 'Automatic rules',
            subtitle: 'Set up rules to automatically assign categories and labels to your records and recognize transfers.',
          ),
          _buildSettingItem(
            context,
            icon: Icons.monetization_on,
            iconColor: Colors.blueAccent,
            title: 'Currencies',
            subtitle: 'Add other currencies, adjust exchange rates',
          ),
          _buildSectionHeader('Other settings'),
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            iconColor: Colors.blueAccent,
            title: 'Notifications',
            subtitle: 'Configure notifications you want to receive',
            screen: const NotificationsScreen(),
          ),
          _buildSettingItem(
            context,
            icon: Icons.lock,
            iconColor: Colors.blueAccent,
            title: 'Security',
            subtitle: 'Protect your app with PIN or Fingerprint',
            screen: const SecuritySettingsScreen(),
          ),
          _buildSettingItem(
            context,
            icon: Icons.settings,
            iconColor: Colors.blueAccent,
            title: 'Advanced settings',
            subtitle: 'Set number format, module after launch or initial day of the month',
            screen: const AdvancedSettingsScreen(),
          ),
          _buildSettingItem(
            context,
            icon: Icons.security,
            iconColor: Colors.blueAccent,
            title: 'Personal data & Privacy',
            subtitle: 'Review and manage your GDPR',
            screen: const PrivacyScreen(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTopItem(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String subtitle, Widget? screen}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: iconColor, size: 30),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen ?? PlaceholderScreen(title: title)));
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String subtitle, Widget? screen}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen ?? PlaceholderScreen(title: title)));
      },
    );
  }
}
