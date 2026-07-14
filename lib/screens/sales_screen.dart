import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/sales_person.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> _addSalesPerson() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddSalesDialog(),
    );

    if (result != null) {
      final person = SalesPerson(
        name: result['name']!,
        phone: result['phone']!,
        email: result['email']!,
        region: result['region']!,
      );
      await context.read<AppProvider>().addSalesPerson(person);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sales ${result['name']} ditambahkan!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Sales')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.salesPersons.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data sales'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.salesPersons.length,
            itemBuilder: (context, index) {
              final person = provider.salesPersons[index];
              final isSelected = provider.currentSalesPerson?.id == person.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSelected
                      ? const BorderSide(color: Color(0xFF6C63FF), width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300],
                    child: Text(
                      person.name[0].toUpperCase(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    ),
                  ),
                  title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('📍 ${person.region}'),
                      if (person.phone.isNotEmpty) Text('📞 ${person.phone}'),
                      if (person.email.isNotEmpty) Text('✉️ ${person.email}'),
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF))
                      : null,
                  onTap: () {
                    provider.setCurrentSalesPerson(person);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sales aktif: ${person.name}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSalesPerson,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class AddSalesDialog extends StatefulWidget {
  const AddSalesDialog({super.key});

  @override
  State<AddSalesDialog> createState() => _AddSalesDialogState();
}

class _AddSalesDialogState extends State<AddSalesDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Sales Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap *', prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'No. Telepon', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _regionCtrl,
              decoration: const InputDecoration(labelText: 'Wilayah *', prefixIcon: Icon(Icons.location_on)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.isEmpty || _regionCtrl.text.isEmpty) return;
            Navigator.pop(context, {
              'name': _nameCtrl.text,
              'phone': _phoneCtrl.text,
              'email': _emailCtrl.text,
              'region': _regionCtrl.text,
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
