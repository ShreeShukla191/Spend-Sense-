import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  void _fetchSettings() async {
    try {
      final data = await _apiService.get('/users/settings/');
      if (mounted) {
        setState(() {
          _user = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateBudget() async {
    final controller = TextEditingController(text: _user?['monthly_budget']?.toString());
    
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Update Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Budget (₹)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _apiService.post('/users/settings/', {
                  'action': 'update_budget',
                  'monthly_budget': controller.text
                });
                _fetchSettings();
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Save'),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text('Failed to load settings.')));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(_user?['username'] ?? 'N/A'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(_user?['email'] ?? 'N/A'),
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Finance Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
            title: const Text('Monthly Budget'),
            subtitle: Text('₹${_user?['monthly_budget'] ?? 0.0}'),
            trailing: const Icon(Icons.edit),
            onTap: _updateBudget,
          ),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Account Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.auto_graph, color: Colors.blue),
            title: const Text('Total Assets'),
            trailing: Text('₹${_user?['assets'] ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.money_off, color: Colors.red),
            title: const Text('Total Loans'),
            trailing: Text('₹${_user?['loans'] ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
