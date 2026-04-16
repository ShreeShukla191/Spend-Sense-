import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  String _source = '';
  String _amount = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'source': _source,
        'amount': _amount,
        'date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      };
      await _apiService.post('/expenses/income/', body);
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
      appBar: AppBar(title: const Text('Add Income')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Income Source (e.g., Salary)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _source = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _amount = val!,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade400)),
                      title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Save Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
