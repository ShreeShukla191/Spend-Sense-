import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  String _serviceName = '';
  String _category = 'Entertainment';
  String _amount = '';
  String _billingCycle = 'Monthly';
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<String> _cycles = ['Monthly', 'Yearly'];
  final List<String> _categories = ['Entertainment', 'Software', 'Gym', 'Utilities', 'General'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'service_name': _serviceName,
        'category': _category,
        'amount': _amount,
        'billing_cycle': _billingCycle,
        'next_due_date': "${_nextDueDate.year}-${_nextDueDate.month.toString().padLeft(2, '0')}-${_nextDueDate.day.toString().padLeft(2, '0')}",
      };
      await _apiService.post('/expenses/subscription/', body);
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
      appBar: AppBar(title: const Text('New Subscription')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Service Name (e.g., Netflix)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _serviceName = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _amount = val!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _category,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _billingCycle,
                      items: _cycles.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _billingCycle = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade400)),
                      title: Text('Next Due Date: ${_nextDueDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.date_range),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _nextDueDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (picked != null) setState(() => _nextDueDate = picked);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Save Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
