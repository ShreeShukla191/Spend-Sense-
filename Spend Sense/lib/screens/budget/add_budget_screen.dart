import 'package:flutter/material.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _amount;

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Budget for $_category set to $_amount!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g., Dining out'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _category = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount Limit', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _amount = val,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveBudget,
              child: const Text('Save Budget', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
