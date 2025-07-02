import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_constant.dart';

class ManageFishScreen extends StatefulWidget {
  final int fisherId;

  const ManageFishScreen({super.key, required this.fisherId});

  @override
  State<ManageFishScreen> createState() => _ManageFishScreenState();
}

class _ManageFishScreenState extends State<ManageFishScreen> {
  List<dynamic> fishList = [];
  bool isLoading = true;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchFish();
  }

  Future<void> fetchFish() async {
    setState(() {
      isLoading = true;
    });
    print("Fetching fish for fisher_id: ${widget.fisherId}");
    try {
      final response = await http.get(Uri.parse('${ApiConstant.getFish}?fisher_id=${widget.fisherId}'));
      print("FetchFish Raw Response: ${response.body}");
      final data = json.decode(response.body);
      print("FetchFish Decoded Response: $data");

      if (data['status'] == true) {
        setState(() {
          fishList = data['fish'];
        });
        print("Fish list updated with ${fishList.length} items.");
      } else {
        print("FetchFish Error: ${data['message']}");
        showSnack(data['message'] ?? 'Error fetching fish');
      }
    } catch (e) {
      print("FetchFish Exception: $e");
      showSnack('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnack(String message) {
    print("SnackBar: $message");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
      print("Image selected: ${picked.path}");
    } else {
      print("Image selection cancelled.");
    }
  }

  Future<void> addOrEditFishDialog({Map<String, dynamic>? fish}) async {
    final isEdit = fish != null;
    print(isEdit ? "Opening Edit Fish Dialog" : "Opening Add Fish Dialog");

    final nameController = TextEditingController(text: fish?['name'] ?? '');
    final descriptionController = TextEditingController(text: fish?['description'] ?? '');
    final priceController = TextEditingController(text: fish?['price']?.toString() ?? '');
    final quantityController = TextEditingController(text: fish?['available_quantity']?.toString() ?? '');
    selectedImage = null;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Fish' : 'Add Fish'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
                TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(selectedImage!, height: 100),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              print("Fish Dialog Cancelled");
              Navigator.pop(context);
            }, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                print(isEdit ? "Updating Fish..." : "Adding Fish...");
                if (isEdit) {
                  updateFish(fish!['fish_id'].toString(), nameController.text, descriptionController.text, priceController.text, quantityController.text);
                } else {
                  addFish(nameController.text, descriptionController.text, priceController.text, quantityController.text);
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addFish(String name, String description, String price, String quantity) async {
    if (name.isEmpty || price.isEmpty || quantity.isEmpty) {
      showSnack('Please fill all required fields');
      return;
    }

    print("Sending Add Fish Request...");
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstant.addFish));
    request.fields['fisher_id'] = widget.fisherId.toString();
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['available_quantity'] = quantity;

    if (selectedImage != null) {
      print("Attaching image: ${selectedImage!.path}");
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print("AddFish Raw Response: $responseData");
      final data = json.decode(responseData);

      if (data['status'] == true) {
        fetchFish();
        showSnack('Fish added successfully');
      } else {
        showSnack(data['message'] ?? 'Error adding fish');
      }
    } catch (e) {
      print("AddFish Exception: $e");
      showSnack('Error: $e');
    }
  }

  Future<void> updateFish(String fishId, String name, String description, String price, String quantity) async {
    if (name.isEmpty || price.isEmpty || quantity.isEmpty) {
      showSnack('Please fill all required fields');
      return;
    }

    print("Sending Update Fish Request for fish_id: $fishId");
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConstant.apiBase}/update_fish.php'));
    request.fields['fish_id'] = fishId;
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['available_quantity'] = quantity;

    if (selectedImage != null) {
      print("Attaching image for update: ${selectedImage!.path}");
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print("UpdateFish Raw Response: $responseData");
      final data = json.decode(responseData);

      if (data['status'] == true) {
        fetchFish();
        showSnack('Fish updated successfully');
      } else {
        showSnack(data['message'] ?? 'Error updating fish');
      }
    } catch (e) {
      print("UpdateFish Exception: $e");
      showSnack('Error: $e');
    }
  }

  Future<void> deleteFish(String fishId) async {
    print("Deleting fish with ID: $fishId");
    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.apiBase}/delete_fish.php'),
        body: {'fish_id': fishId},
      );
      print("DeleteFish Raw Response: ${response.body}");
      final data = json.decode(response.body);

      if (data['status'] == true) {
        fetchFish();
        showSnack('Fish deleted successfully');
      } else {
        showSnack(data['message'] ?? 'Error deleting fish');
      }
    } catch (e) {
      print("DeleteFish Exception: $e");
      showSnack('Error: $e');
    }
  }

  Widget buildFishCard(Map<String, dynamic> fish) {
    print("Building card for fish: ${fish['name']} (ID: ${fish['fish_id']})");
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          leading: fish['image_url'] != null && fish['image_url'].toString().isNotEmpty
              ? Image.network('${ApiConstant.imageBase}/uploads/${fish['image_url']}', width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.image, size: 40, color: Colors.grey),
          title: Text(fish['name'] ?? 'Unknown'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fish['description'] != null)
                Text(fish['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Price: ₹${fish['price']}'),
              Text('Quantity: ${fish['available_quantity']}'),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                addOrEditFishDialog(fish: fish);
              } else if (value == 'delete') {
                deleteFish(fish['fish_id'].toString());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fish',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fishList.isEmpty
          ? const Center(child: Text('No Fish Added'))
          : ListView.builder(
        itemCount: fishList.length,
        itemBuilder: (context, index) => buildFishCard(fishList[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditFishDialog(),
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
