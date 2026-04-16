import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Records'),
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
                  _buildList(_expenses, isExpense: true),
                  _buildList(_incomes, isExpense: false),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isExpense}) {
    if (items.isEmpty) return Center(child: Text("No ${isExpense ? 'expenses' : 'incomes'} found."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: isExpense ? Colors.red : Colors.green),
            title: Text(item['description']?.toString() ?? 'Record'),
            subtitle: Text(item['date']?.toString() ?? ''),
            trailing: Text(
              '${isExpense ? '-' : '+'}₹${item['amount']}',
              style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
