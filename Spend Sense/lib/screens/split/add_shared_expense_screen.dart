import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddSharedExpenseScreen extends StatefulWidget {
  final int groupId;
  final List<dynamic> members;

  const AddSharedExpenseScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<AddSharedExpenseScreen> createState() => _AddSharedExpenseScreenState();
}

class _AddSharedExpenseScreenState extends State<AddSharedExpenseScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  String _amount = '';
  int? _paidById;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _paidById = widget.members[0]['member_id'];
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _paidById == null) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final body = {
        'title': _title,
        'amount': _amount,
        'paid_by': _paidById,
      };
      await _apiService.post('/split/${widget.groupId}/add_shared_expense/', body);
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
      appBar: AppBar(title: const Text('Add Shared Expense')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Expense Title (e.g., Dinner)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _title = val!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Total Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _amount = val!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Paid By', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      initialValue: _paidById,
                      items: widget.members.map((m) => DropdownMenuItem<int>(
                        value: m['member_id'],
                        child: Text(m['member_name'].toString()),
                      )).toList(),
                      onChanged: (val) => setState(() => _paidById = val),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submit,
                      child: const Text('Split It!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
