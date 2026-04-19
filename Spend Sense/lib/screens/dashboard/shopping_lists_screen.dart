import 'package:flutter/material.dart';
import 'add_shopping_list_screen.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  final List<Map<String, dynamic>> _lists = [
    {'title': 'Groceries', 'itemCount': 12, 'completed': 5},
    {'title': 'Office Supplies', 'itemCount': 4, 'completed': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final list = _lists[index];
          final isComplete = list['itemCount'] == list['completed'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Icon(
                isComplete ? Icons.playlist_add_check : Icons.list_alt,
                color: isComplete ? Colors.green : Colors.blueAccent,
                size: 32,
              ),
              title: Text(list['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${list['completed']} / ${list['itemCount']} items completed'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // View list
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newList = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddShoppingListScreen()),
          );
          if (newList != null && mounted) {
            setState(() {
              _lists.add(newList as Map<String, dynamic>);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
