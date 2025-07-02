import 'package:app/Fishers/Screens/View_order.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/Fishers/Screens/manage_fish.dart';

class FisherDashboard extends StatelessWidget {
  final int fisherId;

  const FisherDashboard({super.key, required this.fisherId});

  Future<void> _handleLogout(BuildContext context) async {
    print('Logout button pressed');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                print('Logout cancelled');
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
              onPressed: () {
                print('Logout confirmed');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      print('Clearing SharedPreferences and navigating to LoginScreen');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fisherOptions = [
      {'title': 'Manage Fish', 'icon': Icons.add_box},
      {'title': 'View Orders', 'icon': Icons.list_alt},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.anchor, size: 22, color: Color(0xFF1E3A8A)),
            ),
            SizedBox(width: 10),
            Text(
              "FishersNet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Welcome Fisher! ",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, 30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: fisherOptions.map((item) {
                        return InkWell(
                          onTap: () {
                            print('Tapped on ${item['title']}');
                            if (item['title'] == 'Manage Fish') {
                              print('Navigating to ManageFishScreen with fisherId: $fisherId');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageFishScreen(fisherId: fisherId),
                                ),
                              );
                            } else if (item['title'] == 'View Orders') {
                              print('Navigating to ViewOrdersScreen with fisherId: $fisherId');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewOrdersScreen(fisherId: fisherId),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item['icon'], size: 40, color: Color(0xFF1E3A8A)),
                                const SizedBox(height: 12),
                                Text(
                                  item['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
