import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'add_group_screen.dart';
import 'group_detail_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _groups = [];
  List<dynamic> _filteredGroups = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          _groups = data is List ? data : [];
          _filteredGroups = _groups;
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
      appBar: AppBar(
        title: const Text('Split Groups'),
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
                hintText: 'Search split groups...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredGroups = _groups.where((g) {
                    final name = g['name']?.toString().toLowerCase() ?? '';
                    return name.contains(value.toLowerCase());
                  }).toList();
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredGroups.isEmpty
              ? const Center(child: Text("No groups found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = _filteredGroups[index];
                final groupName = group['name']?.toString() ?? 'Unnamed Group';
                final members = group['members'] is List ? group['members'] as List : [];
                final balances = group['balances'] is List ? group['balances'] as List : [];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    title: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${members.length} Members'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group['id'], groupName: groupName))
                        ).then((_) => _fetchGroups());
                      },
                    ),
                    children: balances.map((bal) {
                      final netRaw = bal['net'];
                      final net = netRaw is num ? netRaw.toDouble() : 0.0;
                      final isPositive = net >= 0;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(bal['member_name']?.toString() ?? 'Unknown'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGroupScreen())).then((_) => _fetchGroups());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
