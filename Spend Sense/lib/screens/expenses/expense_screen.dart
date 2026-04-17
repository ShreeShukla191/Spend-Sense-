import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'add_expense_screen.dart';

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

  void _deleteExpense(int id) async {
    try {
      await _apiService.delete('/expenses/expense/$id/');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted successfully!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      _fetchExpenses();
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
                return Dismissible(
                  key: Key(exp['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _expenses.removeWhere((e) => e['id'] == exp['id']);
                      _filteredExpenses.removeWhere((e) => e['id'] == exp['id']);
                    });
                    _deleteExpense(exp['id']);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                        ),
                        title: Text(
                          exp['category_name']?.toString() ?? 'Uncategorized', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${exp['date'] ?? 'No Date'}', 
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '-₹${exp['amount'] ?? '0.0'}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                               icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                               onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseData: exp))).then((_) => _fetchExpenses());
                               }
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) => _fetchExpenses());
        },
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
