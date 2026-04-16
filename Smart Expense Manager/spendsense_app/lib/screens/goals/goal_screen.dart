import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _goals = [];
  bool _isLoading = true;

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
          _goals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                double progress = 0;
                if (goal['progress_percentage'] != null) {
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
                            Text(goal['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Chip(label: Text(goal['status'])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Saved: ₹${goal['saved_amount']} / ₹${goal['target_amount']}'),
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
    );
  }
}
