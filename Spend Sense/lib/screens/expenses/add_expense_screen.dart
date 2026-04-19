import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expenseData;
  const AddExpenseScreen({super.key, this.expenseData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _allCategories = [];
  
  String _amount = '';
  String _selectedCategory = 'Food'; // Default
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  final List<String> _categoryOptions = ['Food', 'Travel', 'Shopping', 'Bills', 'Others'];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _descriptionController.addListener(() {
      _detectCategoryFromText(_descriptionController.text);
    });
    _fetchCategories();
  }

  @override
  void dispose() {
    if (_isListening) _speech.stop();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _detectCategoryFromText(String text) {
    final lowerText = text.toLowerCase();
    String detectedCategory = _selectedCategory;

    // Detect Category
    if (lowerText.contains('food') || lowerText.contains('restaurant') || lowerText.contains('meal') || lowerText.contains('lunch') || lowerText.contains('dinner') || lowerText.contains('breakfast')) {
      detectedCategory = 'Food';
    } else if (lowerText.contains('bus') || lowerText.contains('uber') || lowerText.contains('taxi') || lowerText.contains('flight') || lowerText.contains('train') || lowerText.contains('travel') || lowerText.contains('cab')) {
      detectedCategory = 'Travel';
    } else if (lowerText.contains('shopping') || lowerText.contains('clothes') || lowerText.contains('shoes') || lowerText.contains('mall')) {
      detectedCategory = 'Shopping';
    } else if (lowerText.contains('bill') || lowerText.contains('electricity') || lowerText.contains('water') || lowerText.contains('internet') || lowerText.contains('rent')) {
      detectedCategory = 'Bills';
    }

    // Detect Amount
    bool stateChanged = false;
    final amountRegExp = RegExp(r'\d+(\.\d+)?');
    final matches = amountRegExp.allMatches(text);
    if (matches.isNotEmpty) {
      final detectedAmount = matches.last.group(0)!;
      if (_amountController.text.isEmpty || _isListening) {
        if (_amountController.text != detectedAmount) {
          _amountController.text = detectedAmount;
          stateChanged = true;
        }
      }
    }

    if (detectedCategory != _selectedCategory) {
      _selectedCategory = detectedCategory;
      stateChanged = true;
    }
    
    if (stateChanged && mounted) {
      setState(() {});
    }
  }

  void _fetchCategories() async {
    try {
      final data = await _apiService.get('/expenses/category/');
      if (mounted) {
        setState(() {
          _allCategories = data is List ? data : [];
          _isLoading = false;
        });

        // If editing, try to map the ID back to the generic category name
        if (widget.expenseData != null) {
          final e = widget.expenseData!;
          _amount = e['amount']?.toString() ?? '';
          _amountController.text = _amount;
          if (e['description'] != null) {
            _descriptionController.text = e['description'].toString();
          }
          if (e['date'] != null) {
            _selectedDate = DateTime.tryParse(e['date']) ?? DateTime.now();
          }
          final catId = e['category'].toString();
          try {
            final match = _allCategories.firstWhere((c) => c['id'].toString() == catId);
            if (_categoryOptions.contains(match['expense_type'])) {
               _selectedCategory = match['expense_type'];
            }
          } catch (_) {}
          setState((){});
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    // Auto-map the generic string to the correct backend UUID/ID reference.
    int? categoryId;
    try {
      final match = _allCategories.firstWhere((c) => c['expense_type'] == _selectedCategory);
      categoryId = match['id'];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database mapping error.')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Missing fields logic automatically bypassed with safe defaults
      final desc = _descriptionController.text.isNotEmpty ? _descriptionController.text : "Quick Add - $_selectedCategory";
      final amountValue = _amountController.text.isNotEmpty ? _amountController.text : _amount;
      final body = {
        'amount': amountValue,
        'description': desc,
        'category': categoryId,
        'payment_mode': "Cash",
        'mood': "Neutral",
        'date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      };
      
      if (widget.expenseData != null) {
         final id = widget.expenseData!['id'];
         await _apiService.put('/expenses/expense/$id/', body);
      } else {
         await _apiService.post('/expenses/expense/', body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _triggerVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
              // Auto-submit when mic session ends and we have an amount
              if (_amountController.text.isNotEmpty && _amountController.text != '0.00' && _amountController.text != '') {
                _submit();
              }
            }
          }
        },
        onError: (val) {
          debugPrint('onError: $val');
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _descriptionController.text = val.recognizedWords;
            });
            if (val.finalResult) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _amountController.text.isNotEmpty) {
                  _submit();
                }
              });
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speech recognition not available or permission denied.')));
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // Auto-submit when manually stopped
      if (_amountController.text.isNotEmpty && _amountController.text != '0.00' && _amountController.text != '') {
        _submit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseData != null ? 'Edit Expense' : 'Add Expense', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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
                      // Amount Display
                      const Text('How much did you spend?', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                          border: InputBorder.none,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        onSaved: (val) => _amount = val!,
                      ),
                      const SizedBox(height: 48),

                      // Description Field
                      const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter description or use voice',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category Dropdown
                      const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                            items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          )
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date Picker
                      const Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Icon(Icons.calendar_month, color: Colors.blue),
                            ]
                          )
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      // Voice Input
                      Center(
                        child: InkWell(
                          onTap: _triggerVoiceInput,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: _isListening ? [Colors.redAccent, Colors.red] : [Colors.blueAccent, Colors.lightBlue]),
                              boxShadow: [BoxShadow(color: _isListening ? Colors.red.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5)],
                            ),
                            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(_isListening ? 'Listening...' : 'Tap to use Voice Add', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: 48),

                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: _submit,
                        child: const Text('SAVE EXPENSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
