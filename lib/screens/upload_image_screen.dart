import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_services.dart';

class UploadImageScreen extends StatefulWidget {
  final int id;
  final String type; // 'fish' or 'magazine'

  UploadImageScreen({required this.id, required this.type});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final ApiService _apiService = ApiService();
  File? _image;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _uploadImage() async {
    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = widget.type == 'fish'
        ? await _apiService.uploadFishImage(fishId: widget.id, image: _image!)
        : await _apiService.uploadMagazineImage(magazineId: widget.id, image: _image!);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
      setState(() {
        _image = null;
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload ${widget.type == 'fish' ? 'Fish' : 'Magazine'} Image')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200, fit: BoxFit.cover)
                : Text('No image selected'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}