import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filament.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _filamentsCollection = 'filaments';
  static const String _productsCollection = 'products';
  static const String _salesCollection = 'sales';

  List<Filament> _filaments = [];
  List<Product> _products = [];
  List<Sale> _sales = [];

  List<Filament> get filaments => _filaments;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;

  Future<void> init() async {
    // Set up real-time listeners for all collections
    _listenToFilaments();
    _listenToProducts();
    _listenToSales();
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

  // Stats
  int get totalFilamentStock => _filaments.fold(0, (sum, f) => sum + f.quantity);

  double get totalSalesAmount => _sales.fold(0.0, (sum, s) => sum + s.price);

  int get totalSalesCount => _sales.length;

  int get totalProductCount => _products.length;
}
