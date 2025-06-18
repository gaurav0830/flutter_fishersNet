import 'package:flutter/material.dart';
// import 'package:app/screens/UserProfile.dart';
import 'package:app/screens/view_magazine_screen.dart';
import 'package:app/screens/add_feedback_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:app/screens/dashboard_view.dart'; // Dashboard that links to other screens
// import 'package:app/screens/view_rescue_screen.dart';
// import 'package:app/screens/book_fish_screen.dart';
import 'package:app/screens/view_fish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late List<Widget> _screens;

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());

    // Defer async logic outside initState
    _loadUserIdAndSetScreens();
  }

  Future<void> _loadUserIdAndSetScreens() async {
    final userId = await UserService.getUserId() ?? 0;

    setState(() {
      _screens = [
        const DashboardView(), // Static Home screen
        ViewFishScreen(),
        ViewMagazineScreen(),
        AddFeedbackScreen(userId: userId),
      ];
    });
  }


  void _precacheImages() {
    final images = [
      'assets/fresh-catch.jpg',
      'assets/fishers.jpg',
      'assets/catch_fish.jpg',
      'assets/available_fish.jpg',
      'assets/blogs.jpg',
      'assets/feedback.jpeg',
      'assets/profile.jpg',
    ];
    for (var path in images) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.set_meal), label: 'Fishes'),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Magazine'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Feedback'),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: const [
            Icon(Icons.anchor, size: 28, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "FishersNet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _onItemTapped(3),
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.jpg"),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
        selectedItemColor: Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }
}
