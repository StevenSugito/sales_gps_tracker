import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/visit_model.dart';
import '../models/order_model.dart';
import '../models/return_model.dart';
import '../models/delivery_model.dart';
import '../models/sales_person.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sales_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSalesPersonTable(db);
      await _createOrdersTable(db);
      await _createReturnsTable(db);
      await _createDeliveriesTable(db);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        storeName TEXT NOT NULL,
        storeAddress TEXT NOT NULL,
        storeType TEXT NOT NULL,
        storePhone TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        photoPath TEXT,
        visitDate INTEGER NOT NULL,
        checkInTime INTEGER NOT NULL,
        checkOutTime INTEGER,
        status TEXT NOT NULL,
        orderValue REAL,
        notes TEXT,
        productsShown TEXT,
        salesPersonId INTEGER
      )
    ''');

    await _createSalesPersonTable(db);
    await _createOrdersTable(db);
    await _createReturnsTable(db);
    await _createDeliveriesTable(db);
  }

  Future _createSalesPersonTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales_persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        region TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');
  }

  Future _createOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER,
        salesPersonId INTEGER NOT NULL,
        orderNumber TEXT NOT NULL,
        productName TEXT NOT NULL,
        productCode TEXT,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        unit TEXT DEFAULT 'pcs',
        status TEXT DEFAULT 'PENDING',
        paymentType TEXT DEFAULT 'CASH',
        orderDate INTEGER NOT NULL,
        notes TEXT,
        photoPath TEXT
      )
    ''');
  }

  Future _createReturnsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS returns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitId INTEGER,
        salesPersonId INTEGER NOT NULL,
        returnNumber TEXT NOT NULL,
        productName TEXT NOT NULL,
        productCode TEXT,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalRefund REAL NOT NULL,
        unit TEXT DEFAULT 'pcs',
        reason TEXT NOT NULL,
        condition TEXT DEFAULT 'GOOD',
        status TEXT DEFAULT 'PENDING',
        returnDate INTEGER NOT NULL,
        notes TEXT,
        photoPath TEXT
      )
    ''');
  }

  Future _createDeliveriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS deliveries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        salesPersonId INTEGER NOT NULL,
        deliveryNumber TEXT NOT NULL,
        courierName TEXT,
        trackingNumber TEXT,
        status TEXT DEFAULT 'PREPARING',
        deliveryDate INTEGER NOT NULL,
        receivedDate INTEGER,
        receivedBy TEXT,
        photoPath TEXT,
        notes TEXT
      )
    ''');
  }

  Future<int> insertSalesPerson(SalesPerson person) async {
    final db = await database;
    return await db.insert('sales_persons', person.toMap());
  }

  Future<List<SalesPerson>> getAllSalesPersons() async {
    final db = await database;
    final maps = await db.query('sales_persons', where: 'isActive = 1');
    return maps.map((m) => SalesPerson.fromMap(m)).toList();
  }

  Future<SalesPerson?> getSalesPerson(int id) async {
    final db = await database;
    final maps = await db.query('sales_persons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SalesPerson.fromMap(maps.first);
  }

  Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('orders', orderBy: 'orderDate DESC');
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  Future<List<OrderModel>> getOrdersBySalesPerson(int salesPersonId) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'salesPersonId = ?',
      whereArgs: [salesPersonId],
      orderBy: 'orderDate DESC',
    );
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'orderDate DESC',
    );
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  Future<double> getTotalOrdersByDate(int startDate, int endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(totalPrice) as total FROM orders WHERE orderDate BETWEEN ? AND ?',
      [startDate, endDate],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertReturn(ReturnModel returnItem) async {
    final db = await database;
    return await db.insert('returns', returnItem.toMap());
  }

  Future<List<ReturnModel>> getAllReturns() async {
    final db = await database;
    final maps = await db.query('returns', orderBy: 'returnDate DESC');
    return maps.map((m) => ReturnModel.fromMap(m)).toList();
  }

  Future<List<ReturnModel>> getReturnsBySalesPerson(int salesPersonId) async {
    final db = await database;
    final maps = await db.query(
      'returns',
      where: 'salesPersonId = ?',
      whereArgs: [salesPersonId],
      orderBy: 'returnDate DESC',
    );
    return maps.map((m) => ReturnModel.fromMap(m)).toList();
  }

  Future<int> updateReturnStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'returns',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertDelivery(DeliveryModel delivery) async {
    final db = await database;
    return await db.insert('deliveries', delivery.toMap());
  }

  Future<List<DeliveryModel>> getAllDeliveries() async {
    final db = await database;
    final maps = await db.query('deliveries', orderBy: 'deliveryDate DESC');
    return maps.map((m) => DeliveryModel.fromMap(m)).toList();
  }

  Future<int> updateDeliveryStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'deliveries',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertVisit(VisitModel visit) async {
    final db = await database;
    return await db.insert('visits', visit.toMap());
  }

  Future<List<VisitModel>> getAllVisits() async {
    final db = await database;
    final maps = await db.query('visits', orderBy: 'visitDate DESC, checkInTime DESC');
    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  Future<List<VisitModel>> getVisitsByDate(int startOfDay, int endOfDay) async {
    final db = await database;
    final maps = await db.query(
      'visits',
      where: 'visitDate BETWEEN ? AND ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'checkInTime DESC',
    );
    return maps.map((map) => VisitModel.fromMap(map)).toList();
  }

  Future<int> updateVisit(VisitModel visit) async {
    final db = await database;
    return await db.update(
      'visits',
      visit.toMap(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  Future<int> deleteVisit(int id) async {
    final db = await database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getDashboardStats(int startDate, int endDate) async {
    final db = await database;

    final visitResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM visits WHERE visitDate BETWEEN ? AND ?',
      [startDate, endDate],
    );
    final totalVisits = visitResult.first['count'] as int;

    final orderResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(totalPrice) as total FROM orders WHERE orderDate BETWEEN ? AND ?',
      [startDate, endDate],
    );
    final totalOrders = orderResult.first['count'] as int;
    final totalOrderValue = orderResult.first['total'] as double? ?? 0.0;

    final returnResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(totalRefund) as total FROM returns WHERE returnDate BETWEEN ? AND ?',
      [startDate, endDate],
    );
    final totalReturns = returnResult.first['count'] as int;
    final totalReturnValue = returnResult.first['total'] as double? ?? 0.0;

    final deliveryResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM deliveries WHERE status IN (?, ?)',
      ['PREPARING', 'SHIPPED'],
    );
    final pendingDeliveries = deliveryResult.first['count'] as int;

    return {
      'totalVisits': totalVisits,
      'totalOrders': totalOrders,
      'totalOrderValue': totalOrderValue,
      'totalReturns': totalReturns,
      'totalReturnValue': totalReturnValue,
      'pendingDeliveries': pendingDeliveries,
    };
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
