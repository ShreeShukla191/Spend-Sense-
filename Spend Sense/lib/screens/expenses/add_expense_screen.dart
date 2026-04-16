import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _categories = [];
  int? _selectedCategoryId;
  String _description = '';
  String _amount = '';
  String _paymentMode = 'Cash';
  String _mood = 'Neutral';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  final List<String> _paymentModes = ['Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking'];
  final List<String> _moods = ['Happy', 'Sad', 'Neutral', 'Angry', 'Excited', 'Anxious'];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      final data = await _apiService.get('/expenses/category/');
      if (mounted) {
        setState(() {
          _categories = data is List ? data : [];
          if (_categories.isNotEmpty) _selectedCategoryId = _categories[0]['id'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'amount': _amount,
        'description': _description,
        'category': _selectedCategoryId,
        'payment_mode': _paymentMode,
        'mood': _mood,
        'date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      };
      await _apiService.post('/expenses/expense/', body);
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
      appBar: AppBar(title: const Text('Add Expense')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description (e.g., KFC Lunch)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _description = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _amount = val!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _selectedCategoryId,
                      items: _categories.map((c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text('${c['icon']} ${c['sub_category']} (${c['main_category']})'),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _paymentMode,
                      items: _paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => _paymentMode = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Mood', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _mood,
                      items: _moods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => _mood = val!),
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
                      child: const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
