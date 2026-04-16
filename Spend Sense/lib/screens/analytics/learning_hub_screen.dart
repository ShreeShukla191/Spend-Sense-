import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final ApiService _apiService = ApiService();
  String _message = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchLearning();
  }

  void _fetchLearning() async {
    try {
      final data = await _apiService.get('/analytics/learning/');
      if (mounted) {
        setState(() {
          _message = data['message'] ?? 'Failed to load learning resources.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Hub')),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 24),
                Text(_message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 48),
                const Text("Future Modules Incoming:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const ListTile(leading: Icon(Icons.book, color: Colors.green), title: Text('Stock Market Fundamentals')),
                const ListTile(leading: Icon(Icons.book, color: Colors.green), title: Text('Mastering Credit Scores')),
              ],
            )),
      ),
    );
  }
}
