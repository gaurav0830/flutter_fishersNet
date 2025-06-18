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
      } else {
        setState(() {
          _errorMessage = response['message'];
        });
      }
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
            colors: [Color(0xFF1E3A8A), Color(0xFFADD8E6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: Duration(milliseconds: 800),
                    child: Text(
                      'Add Feedback',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Feedback Message',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        prefixIcon: Icon(Icons.message, color: Color(0xFF1E3A8A)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? 'Message is required' : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_errorMessage != null)
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade100),
                      ),
                    ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : FadeInUp(
                    duration: const Duration(milliseconds: 1400),
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF1E3A8A), // Border color
                            width: 1.5,               // Border thickness
                          ),
                        ),
                      ),
                      child: const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A), // Text color
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
      ),
    );
  }
}