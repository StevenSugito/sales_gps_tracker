import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/delivery_model.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<DeliveryModel> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    final deliveries = await _db.getAllDeliveries();
    setState(() => _deliveries = deliveries);
  }

  Future<void> _updateStatus(DeliveryModel delivery, String status) async {
    await _db.updateDeliveryStatus(delivery.id!, status);
    _loadDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Pengiriman')),
      body: _deliveries.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada pengiriman'),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deliveries.length,
              itemBuilder: (context, index) => _buildDeliveryCard(_deliveries[index]),
            ),
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
    final statusColors = {
      'PREPARING': Colors.orange,
      'SHIPPED': Colors.blue,
      'IN_TRANSIT': Colors.purple,
      'DELIVERED': Colors.green,
      'RETURNED': Colors.red,
    };

    final statusIcons = {
      'PREPARING': Icons.inventory,
      'SHIPPED': Icons.local_shipping,
      'IN_TRANSIT': Icons.route,
      'DELIVERED': Icons.check_circle,
      'RETURNED': Icons.assignment_return,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (statusColors[delivery.status] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcons[delivery.status] ?? Icons.local_shipping,
                    color: statusColors[delivery.status] ?? Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery.deliveryNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Kurir: ${delivery.courierName}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusColors[delivery.status] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    delivery.status,
                    style: TextStyle(
                      color: statusColors[delivery.status] ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            if (delivery.trackingNumber.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Tracking: ${delivery.trackingNumber}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (delivery.status != 'DELIVERED' && delivery.status != 'RETURNED')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(delivery, 'DELIVERED'),
                  icon: const Icon(Icons.check),
                  label: const Text('Tandai Terkirim'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
