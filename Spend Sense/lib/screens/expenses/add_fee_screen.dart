import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddFeeScreen extends StatefulWidget {
  const AddFeeScreen({super.key});

  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}

class _AddFeeScreenState extends State<AddFeeScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _accounts = [];
  int? _selectedAccountId;
  String _amount = '';
  String _description = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    try {
      final data = await _apiService.get('/expenses/account/');
      if (mounted) {
        setState(() {
          _accounts = data is List ? data : [];
          if (_accounts.isNotEmpty) _selectedAccountId = _accounts[0]['id'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedAccountId == null) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'account': _selectedAccountId,
        'amount': _amount,
        'description': _description,
      };
      await _apiService.post('/expenses/fee/', body);
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
      appBar: AppBar(title: const Text('Add Fee')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Account', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _selectedAccountId,
                      items: _accounts.map((a) => DropdownMenuItem<int>(
                        value: a['id'],
                        child: Text('${a['name']} (₹${a['balance']})'),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Fee Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _amount = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description (e.g., Annual Maintenance)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _description = val!,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Record Fee', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
