import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _cashFlow;
  Map<String, dynamic>? _outlook;
  Map<String, dynamic>? _spending;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  void _fetchAnalytics() async {
    try {
      final cashData = await _apiService.get('/analytics/cash-flow/');
      final outlookData = await _apiService.get('/analytics/outlook/');
      final spendingData = await _apiService.get('/analytics/spending/');
      if (mounted) {
        setState(() {
          _cashFlow = cashData;
          _outlook = outlookData;
          _spending = spendingData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerExport(String format) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generating $format report on backend... Check server logs or download folder.')));
    try {
      if (format == 'PDF') {
        await _apiService.get('/analytics/export/pdf/');
      } else {
        await _apiService.get('/analytics/export/excel/');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export completed successfully!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Note: File stream generated natively. ($e)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Hub')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Cash Flow (Last 6 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildCashFlowCard(),
                const SizedBox(height: 32),
                const Text('6-Month Outlook Projection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildOutlookCard(),
                const SizedBox(height: 32),
                const Text('Top Spending Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildSpendingCard(),
                const SizedBox(height: 32),
                const Text('Data Export Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900, padding: const EdgeInsets.all(16)),
                        onPressed: () => _triggerExport('PDF'),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100, foregroundColor: Colors.green.shade900, padding: const EdgeInsets.all(16)),
                        onPressed: () => _triggerExport('Excel'),
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Export Excel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.indigo),
                    title: const Text('Learning Hub'),
                    subtitle: const Text('Knowledge base and financial literacy materials are locked for premium users.'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Learning Hub module requested.')));
                    },
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildCashFlowCard() {
    if (_cashFlow == null || (_cashFlow!['labels'] as List).isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No cash flow data available.')));
    }
    
    final labels = _cashFlow!['labels'] as List;
    final cashIn = _cashFlow!['cash_in'] as List;
    final cashOut = _cashFlow!['cash_out'] as List;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (ctx, i) => const Divider(),
        itemBuilder: (ctx, i) {
          final cin = (cashIn[i] as num).toDouble();
          final cout = (cashOut[i] as num).toDouble();
          final net = cin - cout;
          return ListTile(
            title: Text(labels[i].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('In: ₹$cin | Out: ₹$cout'),
            trailing: Text(
              'Net: ₹${net.toStringAsFixed(0)}', 
              style: TextStyle(color: net >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutlookCard() {
    if (_outlook == null || (_outlook!['labels'] as List).isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No outlook data available.')));
    }
    final labels = _outlook!['labels'] as List;
    final balances = _outlook!['data'] as List;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: labels.length,
        itemBuilder: (ctx, i) {
          final bal = (balances[i] as num).toDouble();
          return ListTile(
            leading: const Icon(Icons.show_chart, color: Colors.blueAccent),
            title: Text(labels[i].toString()),
            trailing: Text('₹${bal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildSpendingCard() {
    if (_spending == null || (_spending!['categories'] as List).isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No spending data available.')));
    }
    final categories = _spending!['categories'] as List;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: categories.map((cat) {
          final amount = (cat['amount'] as num).toDouble();
          return ListTile(
            title: Text(cat['name'].toString()),
            trailing: Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }
}
