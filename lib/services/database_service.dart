import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filament.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import '../models/lead.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _filamentsCollection = 'filaments';
  static const String _productsCollection = 'products';
  static const String _salesCollection = 'sales';
  static const String _expensesCollection = 'expenses';
  static const String _leadsCollection = 'leads';

  List<Filament> _filaments = [];
  List<Product> _products = [];
  List<Sale> _sales = [];
  List<Expense> _expenses = [];
  List<Lead> _leads = [];

  List<Filament> get filaments => _filaments;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  List<Expense> get expenses => _expenses;
  List<Lead> get leads => _leads;

  Future<void> init() async {
    // Set up real-time listeners for all collections
    _listenToFilaments();
    _listenToProducts();
    _listenToSales();
    _listenToExpenses();
    _listenToLeads();
  }

  // Real-time listeners
  void _listenToFilaments() {
    _firestore
        .collection(_filamentsCollection)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _filaments = snapshot.docs
          .map((doc) => Filament.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void _listenToProducts() {
    _firestore
        .collection(_productsCollection)
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void _listenToSales() {
    _firestore
        .collection(_salesCollection)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _sales = snapshot.docs
          .map((doc) => Sale.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void _listenToExpenses() {
    _firestore
        .collection(_expensesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void _listenToLeads() {
    _firestore
        .collection(_leadsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _leads = snapshot.docs
          .map((doc) => Lead.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  // Filament operations
  Future<void> addFilament(Filament filament) async {
    await _firestore
        .collection(_filamentsCollection)
        .doc(filament.id)
        .set(filament.toMap());
  }

  Future<void> updateFilament(Filament filament) async {
    await _firestore
        .collection(_filamentsCollection)
        .doc(filament.id)
        .update(filament.toMap());
  }

  Future<void> deleteFilament(String id) async {
    await _firestore.collection(_filamentsCollection).doc(id).delete();
  }

  Future<void> updateFilamentQuantity(String id, int newQuantity) async {
    final filament = _filaments.firstWhere((f) => f.id == id);
    final updated = filament.copyWith(quantity: newQuantity);
    await updateFilament(updated);
  }

  // Product operations
  Future<void> addProduct(Product product) async {
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_productsCollection).doc(id).delete();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Sale operations
  Future<void> addSale(Sale sale) async {
    await _firestore
        .collection(_salesCollection)
        .doc(sale.id)
        .set(sale.toMap());
  }

  Future<void> updateSale(Sale sale) async {
    await _firestore
        .collection(_salesCollection)
        .doc(sale.id)
        .update(sale.toMap());
  }

  Future<void> deleteSale(String id) async {
    await _firestore.collection(_salesCollection).doc(id).delete();
  }

  // Expense operations
  Future<void> addExpense(Expense expense) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection(_expensesCollection).doc(id).delete();
  }

  // Lead operations
  Future<void> addLead(Lead lead) async {
    await _firestore
        .collection(_leadsCollection)
        .doc(lead.id)
        .set(lead.toMap());
  }

  Future<void> updateLead(Lead lead) async {
    await _firestore
        .collection(_leadsCollection)
        .doc(lead.id)
        .update(lead.toMap());
  }

  Future<void> deleteLead(String id) async {
    await _firestore.collection(_leadsCollection).doc(id).delete();
  }

  Lead? getLeadById(String id) {
    try {
      return _leads.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lead stats
  int get totalLeadsCount => _leads.length;

  int get convertedLeadsCount =>
      _leads.where((l) => l.status == LeadStatus.converted || l.didBuy).length;

  int get lostLeadsCount =>
      _leads.where((l) => l.status == LeadStatus.lost).length;

  int get pendingFollowUpsCount =>
      _leads.where((l) => l.isOverdueFollowUp).length;

  double get revenueFromLeads => _leads.fold(
        0.0,
        (sum, l) => sum + (l.finalSellingAmount ?? 0.0),
      );

  double get leadConversionRate {
    if (_leads.isEmpty) return 0;
    return convertedLeadsCount / _leads.length * 100;
  }

  // Stats
  int get totalFilamentStock => _filaments.fold(0, (sum, f) => sum + f.quantity);

  double get totalSalesAmount => _sales.fold(0.0, (sum, s) => sum + s.price);

  int get totalSalesCount => _sales.length;

  int get totalProductCount => _products.length;

  double get totalProfit {
    double total = 0;
    for (final sale in _sales) {
      final product = getProductById(sale.productId);
      if (product != null) {
        total += (sale.price - product.costPrice.totalCost);
      }
    }
    return total;
  }
}
