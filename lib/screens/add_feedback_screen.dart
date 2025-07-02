import 'package:app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AddFeedbackScreen extends StatefulWidget {
  final int? userId;

  AddFeedbackScreen({required this.userId});

  @override
  _AddFeedbackScreenState createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isFeedbackLoading = true;
  List<dynamic> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiService.addFeedback(
        userId: widget.userId,
        message: _messageController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully')),
        );
        _messageController.clear();
        _fetchFeedbacks(); // Refresh the list
      } else {
        setState(() {
          _errorMessage = response['message'];
        });
      }
    }
  }

  Future<void> _fetchFeedbacks() async {
    setState(() {
      _isFeedbackLoading = true;
    });

    try {
      final response = await _apiService.getFeedbacks(userId: widget.userId);
      print('Raw Feedback Response: $response'); // Entire response logged

      if (response['status'] == 'success') {
        setState(() {
          _feedbackList = response['data'];
          _isFeedbackLoading = false;
        });

        print('Previous Feedbacks:');
        for (var feedback in _feedbackList) {
          print('Message: ${feedback['message']}, Created At: ${feedback['created_at']}');
        }

      } else {
        setState(() {
          _feedbackList = [];
          _isFeedbackLoading = false;
        });
        print('Failed to fetch feedback: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        _feedbackList = [];
        _isFeedbackLoading = false;
      });
      print('Error fetching feedback: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3674B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Main Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: Duration(milliseconds: 800),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Feedback',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _messageController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'Your Feedback',
                                  labelStyle: TextStyle(color: Colors.grey[700]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.feedback, color: Color(0xFF1E3A8A)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your feedback' : null,
                              ),
                              const SizedBox(height: 20),
                              if (_errorMessage != null)
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 20),
                              _isLoading
                                  ? CircularProgressIndicator(color: Color(0xFF1E3A8A))
                                  : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitFeedback,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1E3A8A),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Previous Feedback',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isFeedbackLoading
                        ? Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                        : _feedbackList.isEmpty
                        ? Text('No feedback found', style: TextStyle(color: Colors.grey[600]))
                        : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _feedbackList.length,
                      itemBuilder: (context, index) {
                        final feedback = _feedbackList[index];
                        String message = feedback['message'] ?? '';
                        String submittedAt = feedback['submitted_at'] ?? feedback['created_at'] ?? '';

                        return FadeInUp(
                          duration: Duration(milliseconds: 200 * (index + 1)),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text(
                                      submittedAt,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
