import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_shared_expense_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupDetailScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  void _fetchGroupDetails() async {
    try {
      final data = await _apiService.get('/split/${widget.groupId}/');
      if (mounted) {
        setState(() {
          _group = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _group == null
              ? const Center(child: Text("Failed to load group details."))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Live Balances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 16),
                    _buildBalancesCard(),
                    const SizedBox(height: 32),
                    const Text('Shared Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 16),
                    _buildExpensesList(),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.receipt_long),
        label: const Text('Add Group Expense'),
        onPressed: () {
          final members = _group!['balances'] ?? [];
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => AddSharedExpenseScreen(groupId: widget.groupId, members: members))
          ).then((_) {
            setState(() => _isLoading = true);
            _fetchGroupDetails();
          });
        },
      ),
    );
  }

  Widget _buildBalancesCard() {
    final balances = _group!['balances'] as List? ?? [];
    if (balances.isEmpty) return const Text('No members found.');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: balances.map((b) {
          final net = (b['net'] as num).toDouble();
          return ListTile(
            leading: CircleAvatar(child: Text(b['member_name'].toString()[0].toUpperCase())),
            title: Text(b['member_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Paid: ₹${b['paid']} | Owed: ₹${b['owed']}'),
            trailing: Text(
              net > 0 ? '+₹${net.toStringAsFixed(0)}' : '-₹${abs(net).toStringAsFixed(0)}',
              style: TextStyle(
                color: net > 0 ? Colors.green : (net < 0 ? Colors.red : Colors.grey),
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double abs(double v) => v < 0 ? -v : v;

  Widget _buildExpensesList() {
    final expenses = _group!['expenses'] as List? ?? [];
    if (expenses.isEmpty) return const Text('No shared expenses yet. Split a dinner!');

    return Column(
      children: expenses.map((e) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(e['title'] ?? 'Expense'),
            subtitle: Text(e['date'] ?? ''),
            trailing: Text('₹${e['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }
}
