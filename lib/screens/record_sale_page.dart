import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../services/toast_service.dart';
import '../models/sale.dart';
import '../widgets/bl_components.dart';

class RecordSalePage extends StatefulWidget {
  const RecordSalePage({super.key});

  @override
  State<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends State<RecordSalePage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProductId;
  final _priceCtrl = TextEditingController();
  int _quantity = 1;
  DateTime _saleDate = DateTime.now();

  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _customerInstaCtrl = TextEditingController();
  final _customerAddressCtrl = TextEditingController();

  SaleSource _source = SaleSource.instagramAd;
  PaymentMethod _paymentMethod = PaymentMethod.bankTransfer;
  final _notesCtrl = TextEditingController();
  bool _followedUp = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerInstaCtrl.dispose();
    _customerAddressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _unitCost {
    if (_selectedProductId == null) return 0;
    final db = context.read<DatabaseService>();
    final product = db.getProductById(_selectedProductId!);
    return product?.costPrice.totalCost ?? 0;
  }

  double get _unitPrice => double.tryParse(_priceCtrl.text) ?? 0;
  double get _totalAmount => _unitPrice * _quantity;
  double get _profit => _totalAmount - _unitCost * _quantity;
  double get _margin => _totalAmount > 0 ? (_profit / _totalAmount * 100) : 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) return;

    final db = context.read<DatabaseService>();
    final sale = Sale(
      id: const Uuid().v4(),
      saleDate: _saleDate,
      productId: _selectedProductId!,
      quantity: _quantity,
      price: _unitPrice,
      paymentMethod: _paymentMethod,
      customer: Customer(
        name: _customerNameCtrl.text.trim(),
        phone: _customerPhoneCtrl.text.trim(),
        instaId: _customerInstaCtrl.text.trim().isEmpty ? null : _customerInstaCtrl.text.trim(),
        address: _customerAddressCtrl.text.trim(),
      ),
      source: _source,
      isFollowedUp: _followedUp,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    await db.addSale(sale);

    if (mounted) {
      final productName = db.getProductById(_selectedProductId!)?.name ?? 'Product';
      Toaster.success(
        context,
        'Sale recorded',
        message: '$productName ×$_quantity → ${_customerNameCtrl.text} · NRS ${_totalAmount.toStringAsFixed(0)}',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;
    final selectedProduct = _selectedProductId != null ? db.getProductById(_selectedProductId!) : null;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyS &&
            HardwareKeyboard.instance.isMetaPressed) {
          _save();
        } else if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: c.bg2,
                border: Border(bottom: BorderSide(color: c.rule, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 18, color: c.muted),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Record Sale',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.w500,
                        color: c.ink, letterSpacing: -0.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormSection(
                              title: 'What sold',
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedProductId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Product',
                                    fillColor: c.bg2,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: BorderSide(color: c.rule)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: BorderSide(color: c.rule)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: BorderSide(color: c.coral, width: 1.5)),
                                  ),
                                  dropdownColor: c.bg2,
                                  style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
                                  items: db.products
                                      .map((p) => DropdownMenuItem(
                                            value: p.id,
                                            child: Row(
                                              children: [
                                                ProductThumb(product: p, size: 28, radius: 4),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(
                                                    '${p.name}  ·  stock: ${p.availableStock}',
                                                    style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedProductId = v;
                                      if (v != null) {
                                        final p = db.getProductById(v);
                                        if (p != null) {
                                          _priceCtrl.text = p.currentSellingPrice.toStringAsFixed(0);
                                        }
                                      }
                                    });
                                  },
                                  validator: (v) => v == null ? 'Select a product' : null,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: BLInput(
                                          controller: _priceCtrl,
                                          label: 'Price per unit',
                                          prefixText: 'NRS ',
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                                    ),
                                    const SizedBox(width: 12),
                                    _QuantityStepper(
                                      value: _quantity,
                                      onChanged: (v) => setState(() => _quantity = v),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: _saleDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(const Duration(days: 1)),
                                    );
                                    if (d != null) setState(() => _saleDate = d);
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Sale date',
                                      filled: true,
                                      fillColor: c.bg2,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(7),
                                          borderSide: BorderSide(color: c.rule)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(7),
                                          borderSide: BorderSide(color: c.rule)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('MMM d, yyyy').format(_saleDate),
                                            style: GoogleFonts.inter(fontSize: 13.5, color: c.ink)),
                                        Icon(Icons.calendar_today_outlined, size: 16, color: c.muted),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _FormSection(
                              title: 'Customer',
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _customerNameCtrl,
                                        label: 'Name',
                                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _customerPhoneCtrl,
                                        label: 'Phone',
                                        keyboardType: TextInputType.phone,
                                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _customerInstaCtrl,
                                        label: 'Instagram handle'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _customerAddressCtrl,
                                        label: 'Address'),
                                  ),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _FormSection(
                              title: 'Marketing & payment',
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: DropdownButtonFormField<SaleSource>(
                                      value: _source,
                                      decoration: InputDecoration(
                                        labelText: 'Source',
                                        filled: true,
                                        fillColor: c.bg2,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.rule)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.rule)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.coral, width: 1.5)),
                                      ),
                                      dropdownColor: c.bg2,
                                      style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
                                      items: SaleSource.values
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                          .toList(),
                                      onChanged: (v) => setState(() => _source = v ?? _source),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<PaymentMethod>(
                                      value: _paymentMethod,
                                      decoration: InputDecoration(
                                        labelText: 'Payment method',
                                        filled: true,
                                        fillColor: c.bg2,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.rule)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.rule)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(7),
                                            borderSide: BorderSide(color: c.coral, width: 1.5)),
                                      ),
                                      dropdownColor: c.bg2,
                                      style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
                                      items: PaymentMethod.values
                                          .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                                          .toList(),
                                      onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                BLInput(
                                    controller: _notesCtrl,
                                    label: 'Notes',
                                    maxLines: 3),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Checkbox(
                                    value: _followedUp,
                                    onChanged: (v) => setState(() => _followedUp = v ?? false),
                                    activeColor: c.coral,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Followed up', style: GoogleFonts.inter(fontSize: 13.5, color: c.ink2)),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Sidebar
                    Container(
                      width: 340,
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: c.rule, width: 1)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Receipt preview
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: c.bg2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: c.rule),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Better Lamps.',
                                      style: GoogleFonts.inter(
                                          color: c.ink, letterSpacing: -0.3)),
                                  Divider(color: c.rule, height: 20),
                                  if (selectedProduct != null)
                                    Text(selectedProduct.name,
                                        style: GoogleFonts.inter(
                                            fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500)),
                                  if (_customerNameCtrl.text.isNotEmpty)
                                    Text(_customerNameCtrl.text,
                                        style: GoogleFonts.inter(fontSize: 13, color: c.muted)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Unit price',
                                          style: GoogleFonts.inter(fontSize: 13, color: c.muted)),
                                      Text('NRS ${_unitPrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                              fontSize: 14, color: c.ink, letterSpacing: -0.3)),
                                    ],
                                  ),
                                  if (_quantity > 1) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Quantity',
                                            style: GoogleFonts.inter(fontSize: 13, color: c.muted)),
                                        Text('×$_quantity',
                                            style: GoogleFonts.inter(
                                                fontSize: 13, color: c.ink, letterSpacing: 0.3)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total',
                                            style: GoogleFonts.inter(
                                                fontSize: 13, color: c.ink, fontWeight: FontWeight.w600)),
                                        Text('NRS ${_totalAmount.toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(
                                                fontSize: 14, color: c.ink,
                                                fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Profit',
                                          style: GoogleFonts.inter(fontSize: 13, color: c.muted)),
                                      Text(
                                        'NRS ${_profit.toStringAsFixed(0)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: _profit >= 0 ? c.coral : c.berry,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_unitPrice > 0)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: c.moss.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(left: BorderSide(color: c.moss, width: 2)),
                                ),
                                child: Text(
                                  'Margin on this sale is ${_margin.toStringAsFixed(1)}%.',
                                  style: GoogleFonts.inter(
                                      color: c.moss, letterSpacing: -0.2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: c.bg2,
                border: Border(top: BorderSide(color: c.rule, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                children: [
                  Text('⌘S save  ·  esc discard',
                      style: GoogleFonts.inter(fontSize: 10, color: c.muted, letterSpacing: 0.5)),
                  const Spacer(),
                  BLButton(label: 'Cancel', kind: BLButtonKind.ghost, onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  BLButton(label: 'Record Sale', kind: BLButtonKind.primary, onPressed: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg2,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: c.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text('Qty',
                style: GoogleFonts.inter(fontSize: 11, color: c.muted)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 16, color: value > 1 ? c.ink : c.muted),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500, color: c.ink),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 16, color: c.ink),
                onPressed: () => onChanged(value + 1),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w500,
                color: c.ink, letterSpacing: -0.27)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.bg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.rule, width: 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ],
    );
  }
}
