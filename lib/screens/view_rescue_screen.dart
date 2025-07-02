import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ViewRescueScreen extends StatefulWidget {
  @override
  _ViewRescueScreenState createState() => _ViewRescueScreenState();
}

class _ViewRescueScreenState extends State<ViewRescueScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _rescues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRescues();
  }

  void _fetchRescues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.viewRescues();

    setState(() {
      _isLoading = false;
      if (response['status'] == 'success') {
        _rescues = response['data'];
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blueAccent;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rescue Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3674B5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3674B5), Color(0xFF578FCA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _rescues.length,
          itemBuilder: (context, index) {
            final rescue = _rescues[index];
            final status = rescue['status'] ?? 'Unknown';

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rescue['fisher_name'] ?? 'Anonymous',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rescue['location'] ?? 'Unknown location',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
