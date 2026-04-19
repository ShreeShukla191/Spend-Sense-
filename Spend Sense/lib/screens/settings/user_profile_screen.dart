import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  bool _is2faEnabled = false;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  void _fetchSettings() async {
    try {
      final data = await _apiService.get('/auth/settings/');
      if (mounted) {
        setState(() {
          _user = data;
          _is2faEnabled = data['is_2fa_enabled'] ?? false;
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
                await _apiService.post('/auth/settings/', {
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

  void _saveSecuritySettings() async {
    try {
      setState(() => _isLoading = true);
      
      if (_oldPasswordController.text.isNotEmpty || 
          _newPasswordController.text.isNotEmpty || 
          _confirmPasswordController.text.isNotEmpty) {
          
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw Exception('New passwords do not match');
        }
        if (_oldPasswordController.text.isEmpty) {
          throw Exception('Please enter old password');
        }

        await _apiService.post('/auth/settings/', {
          'action': 'change_password',
          'old_password': _oldPasswordController.text,
          'new_password': _newPasswordController.text,
        });

        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }

      if (_user?['is_2fa_enabled'] != _is2faEnabled) {
        await _apiService.post('/auth/settings/', {
          'action': 'toggle_2fa',
          'is_2fa_enabled': _is2faEnabled,
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings updated successfully')));
        _fetchSettings();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  void _logoutAll() async {
    try {
      setState(() => _isLoading = true);
      await _apiService.post('/auth/settings/', {'action': 'logout_all'});
      if (!mounted) return;
      await Provider.of<AuthProvider>(context, listen: false).logout();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  void _viewLoginActivity() async {
    try {
      setState(() => _isLoading = true);
      final List<dynamic> data = await _apiService.get('/auth/login-activity/');
      if (mounted) {
        setState(() => _isLoading = false);
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Recent Login Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (data.isEmpty)
                    const Text('No recent logins found.')
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final time = DateTime.tryParse(item['timestamp'] ?? '');
                          final displayTime = time != null ? '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}' : 'Unknown Time';
                          
                          return ListTile(
                            leading: const Icon(Icons.computer),
                            title: Text('IP: ${item['ip_address'] ?? 'Unknown'}'),
                            subtitle: Text('Time: $displayTime\nDevice: ${item['user_agent'] ?? 'Unknown'}'),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load activity: $e')));
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text('Failed to load settings.')));

    return Scaffold(
      appBar: AppBar(title: const Text('User profile')),
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
          const Divider(),
          const SizedBox(height: 16),
          const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextField(
            controller: _oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Old Password',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable 2FA Authentication'),
            value: _is2faEnabled,
            onChanged: (val) {
              setState(() {
                _is2faEnabled = val;
              });
            },
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Login Activity History'),
            trailing: const Text('View', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onTap: _viewLoginActivity,
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Logout From All Devices', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.exit_to_app, color: Colors.red),
            onTap: _logoutAll,
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSecuritySettings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Security Settings'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
