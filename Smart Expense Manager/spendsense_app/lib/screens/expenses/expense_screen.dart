import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _expenses = [];
  bool _isLoading = true;

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
          _expenses = data;
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
      appBar: AppBar(title: const Text('Expenses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final exp = _expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.receipt_long),
                    ),
                    title: Text(exp['description'] ?? 'No Description'),
                    subtitle: Text('${exp['date']} • ${exp['payment_mode']}'),
                    trailing: Text(
                      '-₹${exp['amount']}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for adding an expense
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add expense form goes here!')));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
