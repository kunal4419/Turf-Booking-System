import 'package:flutter/material.dart';

class SportSelectionScreen extends StatelessWidget {
  const SportSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sports = [
      {'name': 'Football', 'icon': Icons.sports_soccer, 'count': '24 Turfs'},
      {'name': 'Cricket', 'icon': Icons.sports_cricket, 'count': '18 Turfs'},
      {'name': 'Badminton', 'icon': Icons.sports_tennis, 'count': '12 Turfs'},
      {'name': 'Tennis', 'icon': Icons.sports_tennis, 'count': '8 Turfs'},
      {'name': 'Basketball', 'icon': Icons.sports_basketball, 'count': '5 Turfs'},
      {'name': 'Volleyball', 'icon': Icons.sports_volleyball, 'count': '3 Turfs'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Sport'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.1,
        ),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                // Navigate to TurfListScreen with selected sport
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sport['icon'] as IconData,
                      size: 40,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sport['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sport['count'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
