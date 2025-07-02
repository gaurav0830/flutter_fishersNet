import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:shimmer/shimmer.dart';

class ViewFishScreen extends StatefulWidget {
  @override
  _ViewFishScreenState createState() => _ViewFishScreenState();
}

class _ViewFishScreenState extends State<ViewFishScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _fishList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFish();
  }

  Future<void> _fetchFish() async {
    try {
      final response = await _apiService.viewFish();
      setState(() {
        _isLoading = false;
        if (response['status'] == 'success') {
          _fishList = response['data'];
        } else {
          _errorMessage = response['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load fish data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF3674B5)))
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Color(0xFF3674B5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate shrink percentage
                double percent = (constraints.maxHeight - kToolbarHeight) / (120 - kToolbarHeight);
                double fontSize = 16 + (10 * percent); // Font ranges from 16 to 26

                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Fishes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize.clamp(16, 26),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final fish = _fishList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: fish['image_url'] != null
                            ? Image.network(
                          fish['image_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, size: 40, color: Color(0xFF1E88E5)),
                        )
                            : Icon(Icons.image, size: 40, color: Color(0xFF1E88E5)),
                      ),
                      title: Text(
                        fish['name'] ?? 'Unknown Fish',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            '₹${fish['price'] ?? 'N/A'}',
                            style: TextStyle(color: Color(0xFF3674B5), fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Available: ${fish['available_quantity'] ?? '0'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, color: Color(0xFF1E88E5)),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                  );
                },
                childCount: _fishList.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 80), // Bottom space to avoid overlapping with FAB or navbar
          ),

        ],
      ),
    );
  }
}
