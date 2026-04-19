import 'package:flutter/material.dart';
import 'add_planned_payment_screen.dart';

class PlannedPaymentsScreen extends StatefulWidget {
  const PlannedPaymentsScreen({super.key});

  @override
  State<PlannedPaymentsScreen> createState() => _PlannedPaymentsScreenState();
}

class _PlannedPaymentsScreenState extends State<PlannedPaymentsScreen> {
  final List<Map<String, dynamic>> _payments = [
    {'title': 'Netflix Subscription', 'amount': 199.0, 'dueDate': '2024-05-01', 'status': 'Upcoming'},
    {'title': 'Rent', 'amount': 15000.0, 'dueDate': '2024-05-05', 'status': 'Upcoming'},
    {'title': 'Electricity Bill', 'amount': 1200.0, 'dueDate': '2024-04-20', 'status': 'Paid'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planned Payments'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          final isPaid = payment['status'] == 'Paid';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Icon(
                isPaid ? Icons.check_circle : Icons.schedule,
                color: isPaid ? Colors.green : Colors.orange,
                size: 32,
              ),
              title: Text(payment['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Due: ${payment['dueDate']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${payment['amount']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(payment['status'], style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPayment = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlannedPaymentScreen()),
          );
          if (newPayment != null && mounted) {
            setState(() {
              _payments.add(newPayment as Map<String, dynamic>);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
