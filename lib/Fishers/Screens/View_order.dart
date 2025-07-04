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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to fetch orders')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final url = '${ApiConstant.apiBase}/update_order_status.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'order_id': orderId,
          'status': newStatus,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated successfully')),
        );

        // Clear orders and refetch to avoid stale data
        setState(() {
          orders = [];
        });
        await fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to update order status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    String currentStatus = order['status'] ?? 'Pending';
    List<String> statusOptions = ['Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order['order_id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Fish: ${order['fish_name']}'),
            Text('Quantity: ${order['quantity']}'),
            Text('Total Price: ₹${order['total_price']}'),
            Text('Ordered by: ${order['user_name']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Update Status: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != currentStatus) {
                        updateOrderStatus(order['order_id'], newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchOrders,
          ),
        ],
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
