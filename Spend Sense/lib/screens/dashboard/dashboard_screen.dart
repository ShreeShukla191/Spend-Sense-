import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../expenses/add_expense_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  void _fetchDashboard() async {
    try {
      final data = await _apiService.get('/analytics/dashboard/');
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SpendSense Wallet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(child: Text("Error loading wallet data: $_error", style: TextStyle(color: Colors.red)))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGreeting(),
                          const SizedBox(height: 24),
                          _buildWalletBalanceCard(),
                          const SizedBox(height: 32),
                          const Text('Category Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildPieChart(),
                          const SizedBox(height: 32),
                          const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildRecentTransactions(),
                          const SizedBox(height: 80), // Padding for FAB
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) => _fetchDashboard());
        },
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildGreeting() {
    // Currently relying on AuthProvider for username
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Good Morning,', style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Hello User!', 
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)
        ),
      ],
    );
  }

  Widget _buildWalletBalanceCard() {
    final balance = _data?['remaining_budget']?.toString() ?? '0.0';
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade900, Colors.deepPurple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(
            '₹$balance',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Income', _data?['total_income']?.toString() ?? '0.0', Icons.arrow_downward, Colors.greenAccent),
              _buildMiniStat('Expenses', _data?['total_expenses']?.toString() ?? '0.0', Icons.arrow_upward, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String amount, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            Text('₹$amount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        )
      ],
    );
  }

  Widget _buildPieChart() {
    final labels = _data?['pie_labels'] as List? ?? [];
    final amounts = _data?['pie_data'] as List? ?? [];
    
    if (amounts.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('No category data available', style: TextStyle(color: Colors.grey)),
      );
    }

    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < amounts.length; i++) {
       final double val = (amounts[i] as num).toDouble();
       sections.add(PieChartSectionData(
         color: colors[i % colors.length],
         value: val,
         title: labels.length > i ? labels[i] : 'Other',
         radius: 50,
         titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
       ));
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        )
      ),
    );
  }

  Widget _buildRecentTransactions() {
     final recents = _data?['recent_expenses'] as List? ?? [];
     if (recents.isEmpty) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No recent transactions.', style: TextStyle(color: Colors.grey)),
        ));
     }

     return Column(
       children: recents.map((txn) {
         return Container(
           margin: const EdgeInsets.only(bottom: 12),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)]
           ),
           child: ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             leading: Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
               child: const Icon(Icons.receipt_long, color: Colors.blueAccent),
             ),
             title: Text(txn['description'] ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             subtitle: Text(txn['date'] ?? '', style: const TextStyle(color: Colors.grey)),
             trailing: Text('-₹${txn['amount'] ?? '0.0'}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
           ),
         );
       }).toList(),
     );
  }
}
