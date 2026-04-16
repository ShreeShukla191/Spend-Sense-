import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _modules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLearningModules();
  }

  void _fetchLearningModules() async {
    try {
      final data = await _apiService.get('/analytics/learning/');
      if (mounted) {
        setState(() {
          _modules = data['modules'] is List ? data['modules'] : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _error = 'Failed to load educational modules: $e';
      });
    }
  }

  IconData _getIcon(String iconString) {
    switch (iconString) {
       case 'trending_up': return Icons.trending_up;
       case 'credit_score': return Icons.credit_score;
       case 'pie_chart': return Icons.pie_chart;
       case 'account_balance': return Icons.account_balance;
       default: return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Learning Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _modules.isEmpty
                 ? const Center(child: Text('No learning modules available.', style: TextStyle(color: Colors.grey)))
                 : ListView.builder(
                     padding: const EdgeInsets.all(16),
                     itemCount: _modules.length,
                     itemBuilder: (context, index) {
                       final mod = _modules[index];
                       return Card(
                         elevation: 3,
                         margin: const EdgeInsets.only(bottom: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         child: InkWell(
                           onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting Module: ${mod['title']}'), backgroundColor: Colors.green));
                           },
                           borderRadius: BorderRadius.circular(16),
                           child: Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(12),
                                   decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                   child: Icon(_getIcon(mod['icon']?.toString() ?? ''), size: 30, color: Colors.blueAccent),
                                 ),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(mod['title'] ?? 'Module Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                       const SizedBox(height: 4),
                                       Text(mod['description'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                       const SizedBox(height: 12),
                                       Row(
                                         children: [
                                           Chip(
                                             label: Text(mod['difficulty'] ?? 'Beginner', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                             backgroundColor: mod['difficulty'] == 'Advanced' ? Colors.redAccent : (mod['difficulty'] == 'Intermediate' ? Colors.orange : Colors.green),
                                             padding: EdgeInsets.zero,
                                             visualDensity: VisualDensity.compact,
                                           ),
                                           const SizedBox(width: 8),
                                           Row(
                                             children: [
                                               const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                               const SizedBox(width: 4),
                                               Text(mod['duration'] ?? '15 mins', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                             ],
                                           )
                                         ],
                                       )
                                     ],
                                   ),
                                 )
                               ],
                             ),
                           ),
                         ),
                       );
                     },
                   ),
    );
  }
}
