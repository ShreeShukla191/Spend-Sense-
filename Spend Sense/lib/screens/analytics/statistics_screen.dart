import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  String _period = '30';

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  void _fetchStatistics() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.get('/analytics/statistics/?period=$_period');
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
        title: const Text('Financial Statistics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (val) {
              setState(() => _period = val);
              _fetchStatistics();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: '7', child: Text('Last 7 Days')),
              PopupMenuItem(value: '30', child: Text('Last 30 Days')),
              PopupMenuItem(value: '90', child: Text('Last 90 Days')),
              PopupMenuItem(value: '365', child: Text('Last 1 Year')),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const Center(child: Text("No statistics data available."));

    final deltaRaw = _data!['delta'];
    final delta = deltaRaw is num ? deltaRaw.toDouble() : 0.0;
    
    final forecastLabelsRaw = _data!['forecast_labels'];
    final forecastLabels = forecastLabelsRaw is List ? List<String>.from(forecastLabelsRaw.map((x) => x.toString())) : <String>[];
    
    final forecastDataRaw = _data!['forecast_data'];
    final forecastData = forecastDataRaw is List ? List<double>.from(forecastDataRaw.map((x) => x is num ? x.toDouble() : 0.0)) : <double>[];

    final subscriptions = _data!['subscriptions'] is List ? _data!['subscriptions'] as List : [];
    final accounts = _data!['accounts'] is List ? _data!['accounts'] as List : [];
    final topAccount = _data!['top_account']?.toString() ?? 'None';

    return RefreshIndicator(
      onRefresh: () async => _fetchStatistics(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: delta >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Net Delta ($_period Days)', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '${delta >= 0 ? '+' : ''}₹${delta.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: delta >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(delta >= 0 ? 'You are saving money!' : 'You are spending more than you earn.', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('6-Month Running Balance Predictor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: forecastData.isEmpty 
              ? const Center(child: Text('Not enough data to project forecast.'))
              : _buildLineChart(forecastData, forecastLabels),
          ),
          
          const SizedBox(height: 32),
          Text('Top Account: $topAccount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 16),
          const Text('Active Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (subscriptions.isEmpty)
            const Text("No active subscriptions.")
          else
            ...subscriptions.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.subscriptions, color: Colors.redAccent),
                title: Text(s['name'] ?? 'Sub', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Next due: ${s['next_due_date'] ?? 'N/A'}'),
                trailing: Text('₹${s['amount']}/${s['billing_cycle']?.toString()[0] ?? '?'}' , style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> data, List<String> labels) {
    List<FlSpot> spots = [];
    double minY = data.isNotEmpty ? data[0] : 0;
    double maxY = data.isNotEmpty ? data[0] : 100;
    
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
      if (data[i] < minY) minY = data[i];
      if (data[i] > maxY) maxY = data[i];
    }
    
    return LineChart(
      LineChartData(
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[value.toInt()].split(' ')[0], style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('₹${_compactNum(value)}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  String _compactNum(double num) {
    if (num >= 100000) return '${(num/100000).toStringAsFixed(1)}L';
    if (num >= 1000) return '${(num/1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(0);
  }
}
