import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  void _fetchGroups() async {
    try {
      final data = await _apiService.get('/split/');
      if (mounted) {
        setState(() {
          _groups = data;
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
      appBar: AppBar(title: const Text('Split Groups')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    title: Text(group['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${(group['members'] as List).length} Members'),
                    children: (group['balances'] as List).map((bal) {
                      final net = (bal['net'] as num).toDouble();
                      final isPositive = net >= 0;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(bal['member_name']),
                        trailing: Text(
                          isPositive ? '+₹${net.abs()}' : '-₹${net.abs()}',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
