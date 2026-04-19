import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food & Drinks', 'icon': Icons.restaurant, 'color': Colors.redAccent},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.lightBlue},
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.orangeAccent},
    {'name': 'Transportation', 'icon': Icons.directions_bus, 'color': Colors.teal},
    {'name': 'Vehicle', 'icon': Icons.directions_car, 'color': Colors.purpleAccent},
    {'name': 'Life & Entertainment', 'icon': Icons.movie, 'color': Colors.greenAccent},
    {'name': 'Communication, PC', 'icon': Icons.computer, 'color': Colors.blue},
    {'name': 'Financial expenses', 'icon': Icons.attach_money, 'color': Colors.tealAccent},
    {'name': 'Investments', 'icon': Icons.trending_up, 'color': Colors.pinkAccent},
    {'name': 'Others', 'icon': Icons.list, 'color': Colors.grey},
    {'name': 'Unknown', 'icon': Icons.help_outline, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFilterDropdown('Accounts', 'All accounts'),
              _buildFilterDropdown('Categories', 'All categories'),
              _buildFilterDropdown('Labels', 'All'),
              _buildFilterDropdown('Currencies', 'All Currencies'),
              _buildFilterDropdown('Record types', 'All Record types'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Reset Filter', style: TextStyle(color: Colors.green, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(color: Colors.white54)),
                dropdownColor: const Color(0xFF333333),
                icon: const Icon(Icons.unfold_more, color: Colors.white54),
                items: const [],
                onChanged: (val) {},
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        elevation: 0,
        title: const Text('Analytics', style: TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green),
            onPressed: _openFilters,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Incomes & Expenses Report'),
            Tab(text: 'Balance Trend'),
            Tab(text: 'Cash flow'),
            Tab(text: 'Advanced Charts and Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomeExpenseReport(),
          const Center(child: Text('Balance Trend', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Cash flow', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Advanced Charts', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseReport() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('', style: TextStyle(color: Colors.white)),
            const Text('April 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Text('March 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Total Income Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Income', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹0.00', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹0.00', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E1E1E),
          child: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Income', style: TextStyle(color: Colors.white70, fontSize: 16))),
              Text('₹0.00', style: TextStyle(color: Colors.white70)),
              SizedBox(width: 40),
              Text('₹0.00', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('', style: TextStyle(color: Colors.white)),
            const Text('April 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Text('March 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),

        // Total Expense Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Expense', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹0.00', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹0.00', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ..._expenseCategories.map((cat) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Icon(cat['icon'], color: cat['color'], size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(cat['name'], style: const TextStyle(color: Colors.white70, fontSize: 16))),
                const Text('₹0.00', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 40),
                const Text('₹0.00', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
