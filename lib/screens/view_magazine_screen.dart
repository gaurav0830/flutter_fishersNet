import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ViewMagazineScreen extends StatefulWidget {
  @override
  _ViewMagazineScreenState createState() => _ViewMagazineScreenState();
}

class _ViewMagazineScreenState extends State<ViewMagazineScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _magazines = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMagazines();
  }

  Future<void> _fetchMagazines() async {
    try {
      final response = await _apiService.viewMagazines();
      setState(() {
        _isLoading = false;
        if (response['status'] == 'success') {
          _magazines = response['data'];
        } else {
          _errorMessage = response['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load magazines';
      });
    }
  }

  void _viewPdf(String fileUrl) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3674B5))),
        ),
      );

      final response = await http.get(Uri.parse(fileUrl));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/magazine.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFViewerScreen(pdfPath: file.path)),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3674B5)))
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: const Color(0xFF3674B5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Magazines',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final magazine = _magazines[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: magazine['image_url'] != null
                              ? Image.network(
                            magazine['image_url'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 60, color: Color(0xFF3674B5)),
                          )
                              : const Icon(Icons.image, size: 60, color: Color(0xFF3674B5)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                magazine['title'] ?? 'Untitled Magazine',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                magazine['content'] ?? 'No description available',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (magazine['file_url'] != null) {
                                      _viewPdf(magazine['file_url']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('PDF file not available'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3674B5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('View PDF',style:TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _magazines.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Bottom space
          ),
        ],
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazine PDF'),
        backgroundColor: const Color(0xFF3674B5),
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        fitPolicy: FitPolicy.BOTH,
      ),
    );
  }
}
