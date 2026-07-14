import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/sales_person.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  SalesPerson? _currentSalesPerson;
  List<SalesPerson> _salesPersons = [];

  SalesPerson? get currentSalesPerson => _currentSalesPerson;
  List<SalesPerson> get salesPersons => _salesPersons;

  Future<void> loadSalesPersons() async {
    _salesPersons = await _db.getAllSalesPersons();
    notifyListeners();
  }

  void setCurrentSalesPerson(SalesPerson person) {
    _currentSalesPerson = person;
    notifyListeners();
  }

  Future<void> addSalesPerson(SalesPerson person) async {
    await _db.insertSalesPerson(person);
    await loadSalesPersons();
  }
}
