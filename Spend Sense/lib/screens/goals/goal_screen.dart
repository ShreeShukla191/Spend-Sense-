import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'add_goal_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _goals = [];
  List<dynamic> _filteredGoals = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'Active', 'Completed', 'Future'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  void _fetchGoals() async {
    try {
      final data = await _apiService.get('/goals/');
      if (mounted) {
        setState(() {
          _goals = data is List ? data : [];
          _filteredGoals = _goals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredGoals = _goals.where((g) {
        final name = g['name']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(_searchController.text.toLowerCase());
        final status = g['status']?.toString() ?? 'Active';
        final matchesStatus = _selectedStatus == 'All' || status.toLowerCase() == _selectedStatus.toLowerCase();
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search goals...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                _applyFilters();
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _statusOptions.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStatus = status;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _filteredGoals.isEmpty
                      ? const Center(child: Text("No goals found."))
                      : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredGoals.length,
              itemBuilder: (context, index) {
                final goal = _filteredGoals[index];
                double progress = 0;
                if (goal['progress_percentage'] is num) {
                   progress = (goal['progress_percentage'] as num).toDouble() / 100.0;
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal['name']?.toString() ?? 'Unnamed Goal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Chip(label: Text(goal['status']?.toString() ?? 'Unknown')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Saved: ₹${goal['saved_amount'] ?? '0.0'} / ₹${goal['target_amount'] ?? '0.0'}'),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[300],
                            color: progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen())).then((_) => _fetchGoals());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
