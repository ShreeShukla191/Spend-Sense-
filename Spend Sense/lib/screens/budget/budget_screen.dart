import 'package:flutter/material.dart';
import 'add_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<Map<String, dynamic>> _budgets = [
    {'category': 'Groceries', 'spent': 5000.0, 'limit': 10000.0},
    {'category': 'Entertainment', 'spent': 3000.0, 'limit': 4000.0},
    {'category': 'Transport', 'spent': 1500.0, 'limit': 2000.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _budgets.length,
        itemBuilder: (context, index) {
          final budget = _budgets[index];
          final progress = budget['spent'] / budget['limit'];
          final isOver = progress > 1.0;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(budget['category'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${budget['spent']} / ₹${budget['limit']}',
                        style: TextStyle(color: isOver ? Colors.red : Colors.grey[700], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress > 1.0 ? 1.0 : progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: isOver ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
