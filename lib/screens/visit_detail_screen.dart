import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit_model.dart';

class VisitDetailScreen extends StatelessWidget {
  final VisitModel visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kunjungan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit.photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(visit.photoPath!),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Toko'),
            _buildInfoRow(Icons.store, 'Nama', visit.storeName),
            _buildInfoRow(Icons.location_on, 'Alamat', visit.storeAddress),
            _buildInfoRow(Icons.category, 'Tipe', visit.storeType),
            if (visit.storePhone.isNotEmpty)
              _buildInfoRow(Icons.phone, 'Telepon', visit.storePhone),
            const Divider(height: 32),
            _buildSectionTitle('Lokasi GPS'),
            _buildInfoRow(Icons.gps_fixed, 'Koordinat', 
              '${visit.latitude.toStringAsFixed(6)}, ${visit.longitude.toStringAsFixed(6)}'),
            _buildInfoRow(Icons.my_location, 'Akurasi', '±${visit.accuracy.toStringAsFixed(1)} meter'),
            const Divider(height: 32),
            _buildSectionTitle('Detail Kunjungan'),
            _buildInfoRow(Icons.calendar_today, 'Tanggal', 
              dateFormat.format(DateTime.fromMillisecondsSinceEpoch(visit.checkInTime))),
            _buildInfoRow(Icons.check_circle, 'Status', visit.status),
            if (visit.orderValue > 0)
              _buildInfoRow(Icons.attach_money, 'Nilai Order', 
                'Rp ${visit.orderValue.toStringAsFixed(0)}'),
            if (visit.notes.isNotEmpty)
              _buildInfoRow(Icons.note, 'Catatan', visit.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}