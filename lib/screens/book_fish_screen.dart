import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:animate_do/animate_do.dart';

class BookFishScreen extends StatefulWidget {
  final int userId;

  BookFishScreen({required this.userId});

  @override
  _BookFishScreenState createState() => _BookFishScreenState();
}

class _BookFishScreenState extends State<BookFishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<dynamic> _fishList = [];
  dynamic _selectedFish;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFish();
  }

  void _fetchFish() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.viewFish();

    setState(() {
      _isLoading = false;
      if (response['status'] == 'success') {
        _fishList = response['data'];
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  void _bookFish() async {
    if (_formKey.currentState!.validate() && _selectedFish != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('DEBUG: Booking fish...');
      print('User ID: ${widget.userId}');
      print('Selected Fish: $_selectedFish');
      print('Fish ID: ${_selectedFish?['fish_id']}');
      print('Quantity Text: ${_quantityController.text}');
      print('Parsed Quantity: ${int.tryParse(_quantityController.text)}');

      final response = await _apiService.bookFish(
        userId: widget.userId,
        fishId: _selectedFish['fish_id'],
        quantity: int.parse(_quantityController.text),
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fish booked successfully')),
        );
        _quantityController.clear();
        _selectedFish = null;
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3674B5), Color(0xFF578FCA)],
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Book Fish',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 1000),
                    child: DropdownButtonFormField<dynamic>(
                      value: _selectedFish,
                      hint: const Text('Select Fish', style: TextStyle(color: Colors.black54)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.set_meal, color: Color(0xFF1E88E5)),
                      ),
                      items: _fishList.map((fish) {
                        return DropdownMenuItem(
                          value: fish,
                          child: Row(
                            children: [
                              fish['image_url'] != null
                                  ? Image.network(
                                fish['image_url'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                              )
                                  : const Icon(Icons.image, size: 40, color: Color(0xFF1E88E5)),
                              const SizedBox(width: 8),
                              Text(fish['name']),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFish = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a fish' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 1200),
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        prefixIcon:
                        const Icon(Icons.format_list_numbered, color: Color(0xFF1E88E5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty ? 'Quantity is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade100),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1600),
                    child: ElevatedButton(
                      onPressed: _bookFish,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF1E3A8A),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Book Fish',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
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
