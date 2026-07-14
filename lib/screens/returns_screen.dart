import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/return_model.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<ReturnModel> _returns = [];
  final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final provider = context.read<AppProvider>();
    final returns = provider.currentSalesPerson != null
        ? await _db.getReturnsBySalesPerson(provider.currentSalesPerson!.id!)
        : await _db.getAllReturns();
    setState(() => _returns = returns);
  }

  Future<void> _addReturn() async {
    final provider = context.read<AppProvider>();
    if (provider.currentSalesPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sales terlebih dahulu!')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddReturnDialog(),
    );

    if (result != null) {
      final returnItem = ReturnModel(
        visitId: 0,
        salesPersonId: provider.currentSalesPerson!.id!,
        returnNumber: 'RET-${DateTime.now().millisecondsSinceEpoch}',
        productName: result['productName'],
        productCode: result['productCode'],
        quantity: result['quantity'],
        unitPrice: result['unitPrice'],
        unit: result['unit'],
        reason: result['reason'],
        condition: result['condition'],
        returnDate: DateTime.now().millisecondsSinceEpoch,
        notes: result['notes'],
      );

      await _db.insertReturn(returnItem);
      _loadReturns();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return berhasil dicatat!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Return')),
      body: _returns.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.assignment_return_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada return'),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _returns.length,
              itemBuilder: (context, index) => _buildReturnCard(_returns[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReturn,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReturnCard(ReturnModel returnItem) {
    final statusColors = {
      'PENDING': Colors.orange,
      'APPROVED': Colors.green,
      'REJECTED': Colors.red,
      'PROCESSED': Colors.blue,
    };

    final reasonLabels = {
      'EXPIRED': 'Kadaluarsa',
      'DAMAGED': 'Rusak',
      'WRONG_ITEM': 'Salah Kirim',
      'CUSTOMER_REQUEST': 'Permintaan Customer',
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
                    color: (statusColors[returnItem.status] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    returnItem.status,
                    style: TextStyle(
                      color: statusColors[returnItem.status] ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _currencyFormat.format(returnItem.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(returnItem.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${returnItem.quantity} ${returnItem.unit} x ${_currencyFormat.format(returnItem.unitPrice)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Alasan: ${reasonLabels[returnItem.reason] ?? returnItem.reason}', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.build, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Kondisi: ${returnItem.condition}', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddReturnDialog extends StatefulWidget {
  const AddReturnDialog({super.key});

  @override
  State<AddReturnDialog> createState() => _AddReturnDialogState();
}

class _AddReturnDialogState extends State<AddReturnDialog> {
  final _productNameCtrl = TextEditingController();
  final _productCodeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _unitPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'pcs';
  String _reason = 'EXPIRED';
  String _condition = 'GOOD';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catat Return'),
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
                    items: ['pcs', 'box', 'kg', 'liter'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
              value: _reason,
              decoration: const InputDecoration(labelText: 'Alasan Return'),
              items: ['EXPIRED', 'DAMAGED', 'WRONG_ITEM', 'CUSTOMER_REQUEST']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _reason = v!),
            ),
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(labelText: 'Kondisi Barang'),
              items: ['GOOD', 'DAMAGED', 'EXPIRED']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _condition = v!),
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
              'reason': _reason,
              'condition': _condition,
              'notes': _notesCtrl.text,
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
