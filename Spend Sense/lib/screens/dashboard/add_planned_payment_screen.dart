import 'package:flutter/material.dart';

class AddPlannedPaymentScreen extends StatefulWidget {
  const AddPlannedPaymentScreen({super.key});

  @override
  State<AddPlannedPaymentScreen> createState() => _AddPlannedPaymentScreenState();
}

class _AddPlannedPaymentScreenState extends State<AddPlannedPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _amount;
  String? _dueDate;

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment $_title added!')));
      Navigator.pop(context, {'title': _title, 'amount': double.parse(_amount!), 'dueDate': _dueDate, 'status': 'Upcoming'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Planned Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Netflix Subscription'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _title = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _amount = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Due Date', hintText: 'YYYY-MM-DD'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _dueDate = val,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _savePayment,
              child: const Text('Save Payment', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
