import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _expenses = [];
  List<dynamic> _filteredExpenses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    try {
      final data = await _apiService.get('/expenses/expense/');
      if (mounted) {
        setState(() {
          _expenses = data is List ? data : [];
          _filteredExpenses = _expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredExpenses = _expenses.where((exp) {
                    final desc = exp['description']?.toString().toLowerCase() ?? '';
                    final cat = exp['category']?.toString().toLowerCase() ?? '';
                    final search = value.toLowerCase();
                    return desc.contains(search) || cat.contains(search);
                  }).toList();
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredExpenses.isEmpty 
              ? const Center(child: Text("No expenses found."))
              : ListView.builder(
              itemCount: _filteredExpenses.length,
              itemBuilder: (context, index) {
                final exp = _filteredExpenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.receipt_long),
                    ),
                    title: Text(exp['description']?.toString() ?? 'No Description', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${exp['date'] ?? 'No Date'} • ${exp['payment_mode'] ?? 'Unknown'}'),
                    trailing: Text(
                      '-₹${exp['amount'] ?? '0.0'}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
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
                    leading: const Icon(Icons.money_off, color: Colors.red),
                    title: const Text('Add Expense'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) => _fetchExpenses());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.green),
                    title: const Text('Add Income'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())).then((_) => _fetchExpenses());
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
