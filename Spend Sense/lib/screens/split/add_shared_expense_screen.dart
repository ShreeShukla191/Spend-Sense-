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
  final _amountController = TextEditingController();
  
  String _title = '';
  double _amount = 0.0;
  int? _paidById;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _paidById = widget.members[0]['member_id'];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically calculate equal share
    final splitAmount = widget.members.isNotEmpty ? (_amount / widget.members.length) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Split Expense', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Expense Title Input
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'What is this for? (e.g., Dinner)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        onSaved: (val) => _title = val!,
                      ),
                      const SizedBox(height: 24),

                      // Input for total amount
                      const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                           setState(() {
                             _amount = double.tryParse(val) ?? 0.0;
                           });
                        },
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 32),

                      // Add participants / Display how much each person should pay
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Participants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Equal Split: ₹${splitAmount.toStringAsFixed(2)}/ea', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10)]
                        ),
                        child: Column(
                          children: widget.members.map((m) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Text(m['member_name'].toString()[0].toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(m['member_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Text(
                                '₹${splitAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Select Payer
                      const Text('Who Paid?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _paidById,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                            items: widget.members.map((m) => DropdownMenuItem<int>(
                              value: m['member_id'],
                              child: Text(m['member_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            )).toList(),
                            onChanged: (val) => setState(() => _paidById = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Button to confirm split
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: _submit,
                        child: const Text('CONFIRM SPLIT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
