import 'package:flutter/material.dart';
import 'forum_models.dart';

class RestaurantSearchPage extends StatefulWidget {
  const RestaurantSearchPage({Key? key}) : super(key: key);

  @override
  State<RestaurantSearchPage> createState() => _RestaurantSearchPageState();
}

class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> allRestaurants = [
    Restaurant(id: 'r1', name: 'Bali Sea Grill'),
    Restaurant(id: 'r2', name: 'Ubud Vegan Café'),
    Restaurant(id: 'r3', name: 'Jimbaran Fish Market'),
  ];
  List<Restaurant> filteredRestaurants = [];
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    filteredRestaurants = allRestaurants;
  }

  void _filter(String query) {
    setState(() {
      filteredRestaurants = allRestaurants
          .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSelect(Restaurant r) {
    setState(() {
      if (selectedIds.contains(r.id)) {
        selectedIds.remove(r.id);
      } else {
        selectedIds.add(r.id);
      }
    });
  }

  void _done() {
    final selected = allRestaurants.where((r) => selectedIds.contains(r.id)).toList();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Restaurants'),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                final r = filteredRestaurants[index];
                final isSelected = selectedIds.contains(r.id);
                return ListTile(
                  title: Text(r.name),
                  trailing: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? Colors.blue : null,
                  ),
                  onTap: () => _toggleSelect(r),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
