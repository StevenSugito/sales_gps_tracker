import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../database/database_helper.dart';
import '../models/visit_model.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import 'camera_screen.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  final _storeNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _orderValueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _storeType = 'Retail';
  String? _photoPath;
  double _latitude = 0;
  double _longitude = 0;
  double _accuracy = 0;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  final List<String> _storeTypes = [
    'Retail', 'Grosir', 'Supermarket', 'Minimarket', 'Warung', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);

    final position = await LocationService.getCurrentPosition();

    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _accuracy = position.accuracy;
        _isLoadingLocation = false;
      });
    } else {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan lokasi. Pastikan GPS aktif.')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    await CameraService.initialize();
    final path = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu lokasi GPS terdeteksi!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final visit = VisitModel(
      storeName: _storeNameCtrl.text,
      storeAddress: _addressCtrl.text,
      storeType: _storeType,
      storePhone: _phoneCtrl.text,
      latitude: _latitude,
      longitude: _longitude,
      accuracy: _accuracy,
      photoPath: _photoPath,
      visitDate: DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      checkInTime: now.millisecondsSinceEpoch,
      orderValue: double.tryParse(_orderValueCtrl.text) ?? 0,
      notes: _notesCtrl.text,
    );

    await _db.insertVisit(visit);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunjungan berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunjungan Baru'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGPSCard(),
              const SizedBox(height: 20),
              _buildPhotoSection(),
              const SizedBox(height: 20),
              _buildTextField('Nama Toko *', _storeNameCtrl, Icons.store),
              const SizedBox(height: 16),
              _buildTextField('Alamat Toko *', _addressCtrl, Icons.location_on, maxLines: 2),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField('No. Telepon', _phoneCtrl, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('Nilai Order (Rp)', _orderValueCtrl, Icons.attach_money, 
                keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('Catatan', _notesCtrl, Icons.note, maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveVisit,
                  icon: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Kunjungan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGPSCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed, color: Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lokasi GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _isLoadingLocation
                  ? const Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Mencari lokasi...', style: TextStyle(fontSize: 13)),
                      ],
                    )
                  : Text(
                      _latitude != 0
                        ? '${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)} (±${_accuracy.toStringAsFixed(1)}m)'
                        : 'Lokasi tidak tersedia',
                      style: const TextStyle(fontSize: 13),
                    ),
              ],
            ),
          ),
          IconButton(
            onPressed: _getLocation,
            icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Toko', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _takePhoto,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
              image: _photoPath != null
                ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                : null,
            ),
            child: _photoPath == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap untuk ambil foto', style: TextStyle(color: Colors.grey)),
                  ],
                )
              : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: label.contains('*') ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _storeType,
      decoration: InputDecoration(
        labelText: 'Tipe Toko',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _storeTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (value) => setState(() => _storeType = value!),
    );
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _orderValueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
