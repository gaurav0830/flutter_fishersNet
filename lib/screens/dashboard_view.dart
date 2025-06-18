import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app/screens/book_fish_screen.dart';
import 'package:app/screens/view_rescue_screen.dart';
import 'package:app/screens/view_magazine_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:app/screens/add_feedback_screen.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? userId;

  final carouselItems = [
    {'image': 'assets/fresh-catch.jpg', 'title': 'Fresh Catch Delivered'},
    {'image': 'assets/fishers.jpg', 'title': 'Support Local Fishers'},
    {'image': 'assets/catch_fish.jpg', 'title': 'Straight from the Sea'},
  ];

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
        'widget':  ViewRescueScreen(),
      },
      {
        'title': 'Read Magazine',
        'image': 'assets/blogs.jpg',
        'widget': ViewMagazineScreen(),
      },
      {
        'title': 'Feedback',
        'image': 'assets/feedback.jpeg',
        'widget': AddFeedbackScreen(userId: null,),
      },
    ];

    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A8A),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Welcome to FishersNet!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Transform.translate(
              offset: const Offset(0, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                    hintText: 'Search fish, articles...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.95,
              ),
              items: carouselItems.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(item['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text("Explore", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Colors.blue)),
            const SizedBox(height: 16),
            ...gridItems.map((item) => InkWell(
              onTap: () {
                if (item.containsKey('widget')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['widget'] as Widget),
                  );
                } else if (item.containsKey('route')) {
                  Navigator.pushNamed(context, item['route'] as String);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(item['image'] as String, height: 160, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }
}
