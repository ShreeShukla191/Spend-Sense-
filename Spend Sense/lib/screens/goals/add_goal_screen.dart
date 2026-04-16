import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _targetAmount = '';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'name': _name,
        'target_amount': _targetAmount,
        'deadline': "${_deadline.year}-${_deadline.month.toString().padLeft(2, '0')}-${_deadline.day.toString().padLeft(2, '0')}",
      };
      await _apiService.post('/goals/', body);
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
      appBar: AppBar(title: const Text('New Goal')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Goal Name (e.g., Vacation)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _name = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Target Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _targetAmount = val!,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade400)),
                      title: Text('Deadline: ${_deadline.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.date_range),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (picked != null) setState(() => _deadline = picked);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
