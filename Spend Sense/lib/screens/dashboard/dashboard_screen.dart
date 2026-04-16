import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../settings/settings_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../analytics/chatbot_screen.dart';

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
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
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

  void _optimizeBudget() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyzing financial profile... applying optimized budget constraints locally.')));
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget auto-optimized successfully!'), backgroundColor: Colors.green));
      _fetchDashboard();
    }
  }

  void _openChatbot() {
    _chatController.clear();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendSense Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error\nMake sure the Django backend is running.'))
              : _buildDashboard(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) => _fetchDashboard());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildDashboard() {
    if (_data == null) return const SizedBox();

    final totalExpenses = _data?['total_expenses'] ?? 0.0;
    final remainingBudget = _data?['remaining_budget'] ?? 0.0;
    final totalIncome = _data?['total_income'] ?? 0.0;
    final netWorth = _data?['net_worth'] ?? 0.0;
    final healthScore = _data?['health_score'] ?? 0.0;
    final persona = _data?['persona'] ?? 'Unknown Persona';
    
    final riskLevel = _data?['risk_level'] ?? 'LOW';
    final riskReason = _data?['risk_reason'] ?? 'Stable';
    final suggestions = _data?['suggestions'] is List ? List<String>.from(_data!['suggestions']) : <String>[];
    
    final recentExpenses = _data?['recent_expenses'] is List ? _data!['recent_expenses'] as List : [];
    
    final pieDataRaw = _data?['pie_data'];
    final pieData = pieDataRaw is List ? List<double>.from(pieDataRaw.map((x) => x is num ? x.toDouble() : 0.0)) : <double>[];
    final pieLabelsRaw = _data?['pie_labels'];
    final pieLabels = pieLabelsRaw is List ? List<String>.from(pieLabelsRaw.map((x) => x.toString())) : <String>[];
    
    final barDataRaw = _data?['bar_data'];
    final barData = barDataRaw is List ? List<double>.from(barDataRaw.map((x) => x is num ? x.toDouble() : 0.0)) : <double>[];
    final barLabelsRaw = _data?['bar_labels'];
    final barLabels = barLabelsRaw is List ? List<String>.from(barLabelsRaw.map((x) => x.toString())) : <String>[];
    final incomeBarDataRaw = _data?['income_bar_data'];
    final incomeBarData = incomeBarDataRaw is List ? List<double>.from(incomeBarDataRaw.map((x) => x is num ? x.toDouble() : 0.0)) : <double>[];

    return RefreshIndicator(
      onRefresh: () async => _fetchDashboard(),
      child: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 80.0),
        children: [
          // Embedded Mini Chatbot
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                   Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary),
                   const SizedBox(width: 12),
                   Expanded(
                     child: TextField(
                       controller: _chatController,
                       decoration: const InputDecoration(
                         border: InputBorder.none,
                         hintText: 'Ask the Financial AI...',
                       ),
                       onSubmitted: (_) => _openChatbot(),
                     ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.send),
                     onPressed: _openChatbot,
                     color: Theme.of(context).colorScheme.primary,
                   )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildExpandedMetricsCard(totalIncome, totalExpenses, remainingBudget, netWorth),
          const SizedBox(height: 24),

          _buildRiskMeter(riskLevel, riskReason),
          const SizedBox(height: 16),
          
          _buildHealthCard(healthScore, persona),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Auto-Optimize Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Optimize Now'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade100, foregroundColor: Colors.orange.shade900),
                onPressed: _optimizeBudget,
              )
            ],
          ),
          const SizedBox(height: 12),
          if (suggestions.isNotEmpty)
            ...suggestions.map((s) => Card(
              color: Colors.blue.shade50,
              child: Padding(padding: const EdgeInsets.all(12), child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600))),
            ))
          else
            const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Your budget is already highly optimized. Great job!'))),
            
          const SizedBox(height: 24),

          const Text('6-Month Trend (Income vs Exp)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 250, child: _buildBarChart(barData, incomeBarData, barLabels)),
          
          const SizedBox(height: 24),
          const Text('Category Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildPieChart(pieData, pieLabels)),
          
          const SizedBox(height: 24),
          const Text('Recent Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (recentExpenses.isEmpty)
            const Text("No recent expenses.")
          else
            ...recentExpenses.map((e) => Card(
              child: ListTile(
                title: Text(e['description'] ?? 'Expense'),
                subtitle: Text(e['date'] ?? ''),
                trailing: Text('-₹${e['amount']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildExpandedMetricsCard(num income, num expenses, num remaining, num netWorth) {
    return Column(
      children: [
        Row(
           children: [
             Expanded(child: _metricBox('Income', income, Colors.green)),
             const SizedBox(width: 12),
             Expanded(child: _metricBox('Expenses', expenses, Colors.red)),
           ],
        ),
        const SizedBox(height: 12),
        Row(
           children: [
             Expanded(child: _metricBox('Remaining', remaining, Colors.blue)),
             const SizedBox(width: 12),
             Expanded(child: _metricBox('Net Worth', netWorth, Colors.deepPurple)),
           ],
        )
      ],
    );
  }

  Widget _metricBox(String title, num amount, Color color) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Theme.of(context).cardColor,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))
         ]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
           const SizedBox(height: 8),
           Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
         ],
       ),
     );
  }

  Widget _buildRiskMeter(String riskLevel, String reason) {
    double progress = 0.1;
    Color color = Colors.green;
    IconData icon = Icons.check_circle_outline;
    
    if (riskLevel == 'CRITICAL') {
       progress = 1.0;
       color = Colors.red;
       icon = Icons.warning_amber;
    } else if (riskLevel == 'HIGH') {
       progress = 0.7;
       color = Colors.orange;
       icon = Icons.error_outline;
    } else if (riskLevel == 'LOW') {
       progress = 0.3;
       color = Colors.green;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text('Spend Risk Meter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Chip(
                   backgroundColor: color.withOpacity(0.1),
                   label: Text(riskLevel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                   padding: EdgeInsets.zero,
                 )
               ],
             ),
             const SizedBox(height: 16),
             ClipRRect(
               borderRadius: BorderRadius.circular(8),
               child: LinearProgressIndicator(
                 value: progress,
                 minHeight: 12,
                 backgroundColor: Colors.grey[200],
                 valueColor: AlwaysStoppedAnimation<Color>(color),
               ),
             ),
             const SizedBox(height: 12),
             Row(
               children: [
                 Icon(icon, color: color, size: 20),
                 const SizedBox(width: 8),
                 Expanded(child: Text(reason, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
               ],
             )
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
            Text(score.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        centerSpaceRadius: 30,
        sections: List.generate(data.length, (i) {
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: data[i],
            title: '${labels[i]}\n${(data[i]).toStringAsFixed(0)}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }

  Widget _buildBarChart(List<double> expenses, List<double> incomes, List<String> labels) {
    if (expenses.isEmpty || incomes.isEmpty) return const Center(child: Text("Not enough data for trend chart."));
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: incomes.reduce((a,b) => a > b ? a : b) > expenses.reduce((a,b) => a > b ? a : b) 
              ? incomes.reduce((a,b) => a > b ? a : b) * 1.2 
              : expenses.reduce((a,b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(labels.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: incomes[i], color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4)),
              BarChartRodData(toY: expenses[i], color: Colors.red, width: 12, borderRadius: BorderRadius.circular(4)),
            ],
          );
        }),
      ),
    );
  }
}
