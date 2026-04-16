import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _accountType = 'Bank';
  String _balance = '0.00';
  bool _isLoading = false;

  final List<String> _types = ['Bank', 'Cash', 'Investment'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'name': _name,
        'account_type': _accountType,
        'balance': _balance,
      };
      await _apiService.post('/expenses/account/', body);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Account')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Account Name (e.g., Chase Checking)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _name = val!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Account Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _accountType,
                      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _accountType = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Initial Balance (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _balance = val!,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Save Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
