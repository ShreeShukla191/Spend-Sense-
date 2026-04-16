import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInvestments();
  }

  void _fetchInvestments() async {
    try {
      final data = await _apiService.get('/analytics/investments/');
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investments Hub')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const Center(child: Text("No investment data available."));

    final totalInvested = _data!['total_invested'] ?? 0.0;
    final totalDividends = _data!['total_dividends'] ?? 0.0;
    final totalFees = _data!['total_fees'] ?? 0.0;
    
    final accounts = _data!['accounts'] is List ? _data!['accounts'] as List : [];
    final dividends = _data!['dividends'] is List ? _data!['dividends'] as List : [];
    final fees = _data!['fees'] is List ? _data!['fees'] as List : [];

    return RefreshIndicator(
      onRefresh: () async => _fetchInvestments(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Invested', totalInvested, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard('Dividends', totalDividends, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard('Fees', totalFees, Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text('Investment Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (accounts.isEmpty)
            const Text("No active investment accounts found.")
          else
            ...accounts.map((acc) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.account_balance, color: Colors.blue),
                ),
                title: Text(acc['name'] ?? 'Account', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(acc['bank_name'] ?? ''),
                trailing: Text('₹${acc['balance']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )),
            
          const SizedBox(height: 24),
          const Text('Recent Dividends & Yields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (dividends.isEmpty)
            const Text("No dividends recorded recently.")
          else
            ...dividends.map((div) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.green),
                title: const Text('Dividend Payout'),
                subtitle: Text(div['date'] ?? ''),
                trailing: Text('+₹${div['amount']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            )),
            
          const SizedBox(height: 24),
          const Text('Recent Fees Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (fees.isEmpty)
            const Text("No fees recorded recently.")
          else
            ...fees.map((f) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.trending_down, color: Colors.red),
                title: Text(f['description'] ?? 'Fee applied'),
                subtitle: Text(f['date'] ?? ''),
                trailing: Text('-₹${f['amount']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, num amount, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
