import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../settings/main_settings_screen.dart';
import 'package:fl_chart/fl_chart.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  void _fetchDashboard() async {
    try {
      final data = await _apiService.get('/analytics/');
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontSize: 28, color: Colors.white)),
        backgroundColor: const Color(0xFF222222),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: const Color(0xFF222222),
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.white, width: 3)),
                            ),
                            child: const Text('Accounts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text('Budgets & Goals', style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('List of accounts', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainSettingsScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF3A4B6B), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.settings, color: Colors.blueAccent, size: 20),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Container(
                            width: 160,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.lightBlue, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Cash', style: TextStyle(color: Colors.white, fontSize: 16)),
                                Text('₹${_data?['remaining_budget'] ?? '20,000.00'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 160,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF3A4B6B), width: 2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Add account', style: TextStyle(color: Colors.lightBlue, fontSize: 18)),
                                Icon(Icons.add_circle, color: Colors.lightBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildActionButton('Account Detail', null)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildActionButton('Records', Icons.list)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildActionButton('Planned payments', Icons.update, textColor: Colors.white)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildActionButton('Shopping lists', Icons.shopping_basket_outlined, textColor: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpeedometers(),
                    const SizedBox(height: 16),
                    _buildBalanceTrend(),
                    const SizedBox(height: 16),
                    _buildExpensesStructure(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton(String title, IconData? icon, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
          ],
          Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSpeedometers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSingleGauge('BALANCE', '20K', Colors.orange, 0.7),
                _buildSingleGauge('CASH FLOW', '0', Colors.red, 0.0),
                _buildSingleGauge('SPENDING', '0', Colors.green, 0.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleGauge(String title, String value, Color activeColor, double percentage) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: 180,
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  sections: [
                    PieChartSectionData(color: activeColor, value: percentage * 100, title: '', radius: 10),
                    PieChartSectionData(color: const Color(0xFF333333), value: (1 - percentage) * 100, title: '', radius: 10),
                    PieChartSectionData(color: Colors.transparent, value: 100, title: '', radius: 10), // Bottom half
                  ],
                ),
              ),
              const Positioned(
                bottom: 20,
                child: Icon(Icons.arrow_upward, color: Colors.grey, size: 20), // Placeholder needle
              )
            ],
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBalanceTrend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance Trend', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            const Text('This month', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${_data?['remaining_budget'] ?? '20,000.00'}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.remove_circle, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text('0%', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (val, meta) => Text('${val.toInt()} Apr', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        interval: 4,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => Text('${val.toInt()}K', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        interval: 5,
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 20), FlSpot(4, 20), FlSpot(7, 20), FlSpot(11, 20), FlSpot(15, 20), FlSpot(19, 20)
                      ],
                      isCurved: false,
                      color: Colors.lightBlueAccent,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minX: 1, maxX: 30, minY: 0, maxY: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesStructure() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(16)),
        height: 200,
        width: double.infinity,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses Structure', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            Spacer(),
            Center(
              child: Text(
                'There are no data in the\nselected time interval.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
