import 'package:flutter/material.dart';

class AddShoppingListScreen extends StatefulWidget {
  const AddShoppingListScreen({super.key});

  @override
  State<AddShoppingListScreen> createState() => _AddShoppingListScreenState();
}

class _AddShoppingListScreenState extends State<AddShoppingListScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _itemCount;

  void _saveList() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shopping List $_title created!')));
      Navigator.pop(context, {'title': _title, 'itemCount': int.parse(_itemCount!), 'completed': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shopping List')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'List Title', hintText: 'e.g., Groceries'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _title = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Number of Items'),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _itemCount = val,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveList,
              child: const Text('Save List', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
