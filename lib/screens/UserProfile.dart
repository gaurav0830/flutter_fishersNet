// ... existing imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/UserProfileService.dart';
import 'package:app/screens/ChangePassword.dart'; // Import your change password form

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _contactController;

  bool isLoading = true;
  Map<String, dynamic>? profile;
  late AnimationController _animController;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactController = TextEditingController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final data = await UserProfileService.fetchUserProfile();
    if (data?['success'] == true) {
      final user = data?['data'];
      setState(() {
        profile = user;
        _nameController.text = user?['name'] ?? '';
        _contactController.text = user?['phone'] ?? '';
        isLoading = false;
        _animController.forward();
      });
    } else {
      setState(() => isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data?['message'] ?? 'Error')));
      }
    }
  }

  Future<void> updateProfile() async {
    final res = await UserProfileService.updateUserProfile(
      _nameController.text.trim(),
      _contactController.text.trim(),
    );
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openChangePasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChangePasswordForm(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3674B5),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SlideTransition(
        position: _offset,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildPasswordCard(),
              const SizedBox(height: 30),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircleAvatar(
                      backgroundImage: AssetImage("assets/profile.jpg"),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "User Info",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: updateProfile,
                icon: const Icon(Icons.save),
                label: const Text("Update Profile", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3674B5),
                  iconColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.lock, size: 70, color: Colors.blueGrey),
                  SizedBox(height: 10),
                  Text(
                    "Change Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChangePasswordModal(context),
                icon: const Icon(Icons.password),
                label: const Text("Change Password", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
