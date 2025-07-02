import 'package:flutter/material.dart';
import 'package:app/screens/book_fish_screen.dart';
import 'package:app/screens/view_rescue_screen.dart';
import 'package:app/screens/view_magazine_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:app/screens/add_feedback_screen.dart';
import 'package:app/screens/UserProfile.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DashboardView({Key? key, this.onProfileTap}) : super(key: key);
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    final id = await UserService.getUserId();
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> gridItems = [
      {
        'title': 'Book a Fish',
        'image': 'assets/catch_fish.jpg',
        'widget': BookFishScreen(userId: userId!),
      },
      {
        'title': 'Rescue Info',
        'image': 'assets/fishers.jpg',
        'widget': ViewRescueScreen(),
      },
      {
        'title': 'Read Magazine',
        'image': 'assets/blogs.jpg',
        'widget': ViewMagazineScreen(),
      },
      {
        'title': 'Feedback',
        'image': 'assets/feedback.jpeg',
        'widget': AddFeedbackScreen(userId: userId),
      },
    ];

    return Scaffold(
      body: Stack(
        children: [

          // Top Image
          Column(
            children: [
              Stack(
                children: [

                  // Background Image
                  Image.asset(
                    'assets/top-image.jpeg',
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // Overlay content: Title & Profile
                  Positioned(
                    top: 50,
                    left: 16,
                    child: const Text(
                      "FishersNet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 50,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onProfileTap != null) {
                          widget.onProfileTap!();
                        }
                      },

                      child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/profile.jpg"),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [

                // Spacer for image height minus overlap
                const SizedBox(height: 210),

                // White Card Overlapping Image
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Search Bar
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        shadowColor: Colors.blue.withOpacity(0.2),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search fish, articles...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.search, color: Colors.blue),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 44),

                      const Text(
                        "Explore",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                      const SizedBox(height: 16),

                      Column(
                        children: gridItems.map((item) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => item['widget'] as Widget),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: Image.asset(
                                          item['image'] as String,
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                            color: Colors.black.withOpacity(0.3), // Tint over the image
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => item['widget'] as Widget),
                                            );
                                          },
                                          icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.blue),
                                          label: const Text(
                                            'Explore',
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
