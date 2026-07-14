import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<OrderModel> _orders = [];
  final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = context.read<AppProvider>();
    final orders = provider.currentSalesPerson != null
        ? await _db.getOrdersBySalesPerson(provider.currentSalesPerson!.id!)
        : await _db.getAllOrders();
    setState(() => _orders = orders);
  }

  Future<void> _addOrder() async {
    final provider = context.read<AppProvider>();
    if (provider.currentSalesPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sales terlebih dahulu!')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddOrderDialog(),
    );

    if (result != null) {
      final order = OrderModel(
        visitId: 0,
        salesPersonId: provider.currentSalesPerson!.id!,
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        productName: result['productName'],
        productCode: result['productCode'],
        quantity: result['quantity'],
        unitPrice: result['unitPrice'],
        unit: result['unit'],
        paymentType: result['paymentType'],
        orderDate: DateTime.now().millisecondsSinceEpoch,
        notes: result['notes'],
      );

      await _db.insertOrder(order);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order berhasil disimpan!')),
        );
      }
    }
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    await _db.updateOrderStatus(order.id!, newStatus);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: _orders.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada order'),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrder,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColors = {
      'PENDING': Colors.orange,
      'CONFIRMED': Colors.blue,
      'DELIVERED': Colors.green,
      'CANCELLED': Colors.red,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusColors[order.status] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColors[order.status] ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _currencyFormat.format(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6C63FF)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${order.quantity} ${order.unit} x ${_currencyFormat.format(order.unitPrice)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(order.orderNumber, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(order.paymentType, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (order.status == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(order, 'CONFIRMED'),
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(order, 'CANCELLED'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Batal'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['SEMUA', 'PENDING', 'CONFIRMED', 'DELIVERED', 'CANCELLED'].map((status) {
                return ActionChip(
                  label: Text(status),
                  onPressed: () async {
                    Navigator.pop(context);
                    if (status == 'SEMUA') {
                      _loadOrders();
                    } else {
                      final orders = await _db.getOrdersByStatus(status);
                      setState(() => _orders = orders);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  final _productNameCtrl = TextEditingController();
  final _productCodeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _unitPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'pcs';
  String _paymentType = 'CASH';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _productNameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk *')),
            TextField(controller: _productCodeCtrl, decoration: const InputDecoration(labelText: 'Kode Produk')),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    decoration: const InputDecoration(labelText: 'Qty *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                    items: ['pcs', 'box', 'kg', 'liter', 'meter'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _unitPriceCtrl,
              decoration: const InputDecoration(labelText: 'Harga Satuan *', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _paymentType,
              decoration: const InputDecoration(labelText: 'Cara Bayar'),
              items: ['CASH', 'CREDIT', 'TRANSFER'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _paymentType = v!),
            ),
            TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Catatan'), maxLines: 2),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_productNameCtrl.text.isEmpty || _quantityCtrl.text.isEmpty || _unitPriceCtrl.text.isEmpty) return;
            Navigator.pop(context, {
              'productName': _productNameCtrl.text,
              'productCode': _productCodeCtrl.text,
              'quantity': int.parse(_quantityCtrl.text),
              'unitPrice': double.parse(_unitPriceCtrl.text),
              'unit': _unit,
              'paymentType': _paymentType,
              'notes': _notesCtrl.text,
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
