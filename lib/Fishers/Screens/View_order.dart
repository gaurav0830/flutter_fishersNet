import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_constant.dart';

class ViewOrdersScreen extends StatefulWidget {
  final int fisherId;

  const ViewOrdersScreen({super.key, required this.fisherId});

  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    final url = '${ApiConstant.apiBase}/view_orders.php?fisher_id=${widget.fisherId}';
    print("Fetching Orders from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = json.decode(response.body);
      print("Decoded JSON: $data");

      if (data['status'] == true) {
        setState(() {
          orders = data['orders'];
        });
        print("Orders Fetched: ${orders.length}");
      } else {
        print("Error Message from API: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to fetch orders')),
        );
      }
    } catch (e) {
      print("Error while fetching orders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text('Order ID: ${order['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fish: ${order['fish_name']}'),
            Text('Quantity: ${order['quantity']}'),
            Text('Total Price: ₹${order['total_price']}'),
            Text('Ordered by: ${order['user_name']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text('No Orders Found'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) => buildOrderCard(orders[index]),
      ),
    );
  }
}
