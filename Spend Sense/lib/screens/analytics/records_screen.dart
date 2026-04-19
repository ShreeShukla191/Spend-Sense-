import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/add_income_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _expenses = [];
  List<dynamic> _incomes = [];
  bool _isLoading = true;
  String _selectedTime = '1 month';
  final List<String> _timeOptions = ['1 week', '1 month', '12 weeks'];
  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() async {
    try {
      final data = await _apiService.get('/analytics/records/');
      if (mounted) {
        setState(() {
          _expenses = data['expenses'] is List ? data['expenses'] : [];
          _incomes = data['incomes'] is List ? data['incomes'] : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<dynamic>> _groupExpenses() {
    final Map<String, List<dynamic>> map = {};
    for (var exp in _expenses) {
      final group = exp['category__expense_type']?.toString() ?? 'Uncategorized';
      if (!map.containsKey(group)) map[group] = [];
      map[group]!.add(exp);
    }
    return map;
  }

  Map<String, List<dynamic>> _groupIncomes() {
    final Map<String, List<dynamic>> map = {};
    for (var inc in _incomes) {
      final group = inc['source']?.toString() ?? 'Other';
      if (!map.containsKey(group)) map[group] = [];
      map[group]!.add(inc);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Records'),
          actions: [
            DropdownButton<String>(
              value: _selectedTime,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: const Color(0xFF222222),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTime = newValue;
                    _fetchRecords(); // optionally pass filter to backend or filter locally
                  });
                }
              },
              items: _timeOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Incomes'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildGroupedList(_groupExpenses(), isExpense: true),
                  _buildGroupedList(_groupIncomes(), isExpense: false),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) => _fetchRecords());
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Add Income'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())).then((_) => _fetchRecords());
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGroupedList(Map<String, List<dynamic>> groupedItems, {required bool isExpense}) {
    if (groupedItems.isEmpty) return Center(child: Text("No ${isExpense ? 'expenses' : 'incomes'} found."));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, index) {
        String groupName = groupedItems.keys.elementAt(index);
        List<dynamic> items = groupedItems[groupName]!;
        
        double total = items.fold(0.0, (sum, item) {
           final amt = item['amount'];
           return sum + (amt is num ? amt.toDouble() : double.tryParse(amt.toString()) ?? 0.0);
        });

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${items.length} records'),
            trailing: Text(
              '${isExpense ? '-' : '+'}₹${total.toStringAsFixed(2)}', 
              style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            children: items.map((item) {
              return ListTile(
                leading: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: isExpense ? Colors.red : Colors.green),
                title: Text(item['description']?.toString() ?? (isExpense ? 'Expense' : 'Income')),
                subtitle: Text('${item['date']?.toString() ?? ''} ${isExpense && item['category__sub_category'] != null ? '• ${item['category__sub_category']}' : ''}'),
                trailing: Text(
                  '${isExpense ? '-' : '+'}₹${item['amount']}',
                  style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
