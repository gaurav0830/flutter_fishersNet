import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:animate_do/animate_do.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              FadeInDown(
                duration: Duration(milliseconds: 800),
                child: Text(
                  'Fishes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchFish,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _fishList.length,
                              itemBuilder: (context, index) {
                                final fish = _fishList[index];
                                return FadeInUp(
                                  duration: Duration(milliseconds: 300 * (index + 1)),
                                  child: Card(
                                    margin: EdgeInsets.only(bottom: 16),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(16),
                                        leading: fish['image_url'] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  fish['image_url'],
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      Icon(Icons.image, size: 40, color: Color(0xFF1E88E5)),
                                                ),
                                              )
                                            : Icon(Icons.image, size: 40, color: Color(0xFF1E88E5)),
                                        title: Text(
                                          fish['name'] ?? 'Unknown Fish',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(
                                              'Price: ₹${fish['price']?.toString() ?? 'N/A'}',
                                              style: TextStyle(
                                                color: Color(0xFF1E88E5),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Available: ${fish['available_quantity']?.toString() ?? '0'}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF1E88E5),
                                        ),
                                        onTap: () {
                                          // Handle fish selection
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}