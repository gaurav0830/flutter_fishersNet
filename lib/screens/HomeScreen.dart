import 'package:flutter/material.dart';
import 'package:app/screens/UserProfile.dart';
import 'package:app/screens/view_magazine_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:app/screens/dashboard_view.dart';
import 'package:app/screens/view_fish_screen.dart';
import 'book_fish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<Widget> _screens = [];
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());
    _loadUserIdAndSetScreens();
  }

  Future<void> _loadUserIdAndSetScreens() async {
    final userId = await UserService.getUserId() ?? 0;
    setState(() {
      _userId = userId;
      _screens = [
        DashboardView(onProfileTap: () => _onItemTapped(3), userId: _userId),
        ViewFishScreen(),
        ViewMagazineScreen(),
        UserProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _screens.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userId > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookFishScreen(userId: _userId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User ID not loaded yet')),
            );
          }
        },
        backgroundColor: const Color(0xFF3674B5),
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home,
                    size: 24,
                    color: _selectedIndex == 0
                        ? const Color(0xFF3674B5)
                        : Colors.grey),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.set_meal,
                    size: 24,
                    color: _selectedIndex == 1
                        ? const Color(0xFF3674B5)
                        : Colors.grey),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: Icon(Icons.menu_book,
                    size: 24,
                    color: _selectedIndex == 2
                        ? const Color(0xFF3674B5)
                        : Colors.grey),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(Icons.person,
                    size: 24,
                    color: _selectedIndex == 3
                        ? const Color(0xFF3674B5)
                        : Colors.grey),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
