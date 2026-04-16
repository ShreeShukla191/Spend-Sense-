import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_subscription_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  void _fetchSubscriptions() async {
    try {
      final data = await _apiService.get('/expenses/subscription/');
      if (mounted) {
        setState(() {
          _subscriptions = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptions.isEmpty
              ? const Center(child: Text("No active subscriptions found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = _subscriptions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.subscriptions),
                        ),
                        title: Text(sub['service_name'] ?? 'Unknown Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Due: ${sub['next_due_date']}  •  ${sub['billing_cycle']}'),
                        trailing: Text(
                          '₹${sub['amount'] ?? 0.0}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen())).then((_) => _fetchSubscriptions());
        },
      ),
    );
  }
}
