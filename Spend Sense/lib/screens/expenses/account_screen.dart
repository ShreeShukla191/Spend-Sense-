import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_account_screen.dart';
import 'add_dividend_screen.dart';
import 'add_fee_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    try {
      final data = await _apiService.get('/expenses/account/');
      if (mounted) {
        setState(() {
          _accounts = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Accounts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(child: Text("No accounts configured yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final acc = _accounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(acc['account_type'] == 'Investment' ? Icons.trending_up : Icons.account_balance),
                        ),
                        title: Text(acc['name'] ?? 'Unknown Account', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(acc['account_type'] ?? 'Bank'),
                        trailing: Text(
                          '₹${acc['balance'] ?? 0.0}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance, color: Colors.blue),
                    title: const Text('Add Account'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAccountScreen())).then((_) => _fetchAccounts());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.green),
                    title: const Text('Record Dividend'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDividendScreen())).then((_) => _fetchAccounts());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.money_off, color: Colors.red),
                    title: const Text('Record Fee'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFeeScreen())).then((_) => _fetchAccounts());
                    },
                  ),
                ],
              ),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
