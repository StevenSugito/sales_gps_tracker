import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/visit_model.dart';
import '../providers/app_provider.dart';
import 'add_visit_screen.dart';
import 'visit_detail_screen.dart';
import 'orders_screen.dart';
import 'returns_screen.dart';
import 'delivery_screen.dart';
import 'sales_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<VisitModel> _visits = [];
  Map<String, dynamic> _stats = {};
  int _selectedTab = 0;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<AppProvider>().loadSalesPersons();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final visits = _selectedTab == 0
        ? await _db.getAllVisits()
        : _selectedTab == 1
            ? await _db.getVisitsByDate(startOfDay, endOfDay)
            : await _db.getAllVisits();

    final stats = await _db.getDashboardStats(startOfDay, endOfDay);

    setState(() {
      _visits = visits;
      _stats = stats;
    });
  }

  final List<Widget> _screens = [];

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      const OrdersScreen(),
      const ReturnsScreen(),
      const DeliveryScreen(),
      const SalesScreen(),
    ];

    return Scaffold(
      body: screens[_selectedNavIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedNavIndex = index);
          if (index == 0) _loadData();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Order'),
          NavigationDestination(icon: Icon(Icons.assignment_return), label: 'Return'),
          NavigationDestination(icon: Icon(Icons.local_shipping), label: 'Kirim'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Sales'),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales GPS Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showSalesSelector(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsGrid(),
          _buildTabBar(),
          Expanded(child: _buildVisitList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVisitScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Kunjungan'),
      ),
    );
  }

  void _showSalesSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final provider = context.watch<AppProvider>();
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Sales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...provider.salesPersons.map((person) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(person.name),
                subtitle: Text(person.region),
                trailing: provider.currentSalesPerson?.id == person.id
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  provider.setCurrentSalesPerson(person);
                  Navigator.pop(context);
                },
              )),
              if (provider.salesPersons.isEmpty)
                const Center(child: Text('Belum ada data sales')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildStatCard('Kunjungan', '${_stats['totalVisits'] ?? 0}', Icons.store, Colors.blue),
          _buildStatCard('Order', 'Rp${_formatNumber(_stats['totalOrderValue'] ?? 0)}', Icons.shopping_cart, Colors.green),
          _buildStatCard('Return', 'Rp${_formatNumber(_stats['totalReturnValue'] ?? 0)}', Icons.assignment_return, Colors.orange),
          _buildStatCard('Pengiriman', '${_stats['pendingDeliveries'] ?? 0}', Icons.local_shipping, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Semua')),
          ButtonSegment(value: 1, label: Text('Hari Ini')),
          ButtonSegment(value: 2, label: Text('Dikunjungi')),
        ],
        selected: {_selectedTab},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() => _selectedTab = newSelection.first);
          _loadData();
        },
      ),
    );
  }

  Widget _buildVisitList() {
    if (_visits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada kunjungan'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length,
      itemBuilder: (context, index) => _buildVisitCard(_visits[index]),
    );
  }

  Widget _buildVisitCard(VisitModel visit) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VisitDetailScreen(visit: visit)),
          );
          _loadData();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: Color(0xFF6C63FF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(visit.storeAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(visit.checkInTime)), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              if (visit.orderValue > 0)
                Text('Rp${visit.orderValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
