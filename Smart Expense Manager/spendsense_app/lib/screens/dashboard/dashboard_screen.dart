import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

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
      final data = await _apiService.get('/');
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
      appBar: AppBar(
        title: const Text('SpendSense Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error\nMake sure the Django backend is running.'))
              : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    if (_data == null) return const SizedBox();

    final totalExpenses = _data!['total_expenses'];
    final remainingBudget = _data!['remaining_budget'];
    final healthScore = _data!['health_score'];
    final persona = _data!['persona'];
    final pieData = List<double>.from((_data!['pie_data'] as List).map((x) => x is num ? x.toDouble() : 0.0));
    final pieLabels = List<String>.from(_data!['pie_labels']);

    return RefreshIndicator(
      onRefresh: () async => _fetchDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMetricsCard(totalExpenses, remainingBudget),
          const SizedBox(height: 16),
          _buildHealthCard(healthScore, persona),
          const SizedBox(height: 24),
          const Text('Expenses by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: _buildPieChart(pieData, pieLabels),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(num expenses, num remaining) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Spent This Month', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('₹${expenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Remaining Budget', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('₹${remaining.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(num score, String persona) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              color: score >= 70 ? Colors.green : score >= 40 ? Colors.orange : Colors.red,
            ),
            Text(score.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        title: const Text('Financial Persona'),
        subtitle: Text(persona, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPieChart(List<double> data, List<String> labels) {
    if (data.isEmpty) return const Center(child: Text("No expenses recorded."));

    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(data.length, (i) {
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: data[i],
            title: '${labels[i]}\n${(data[i]).toStringAsFixed(0)}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }
}
