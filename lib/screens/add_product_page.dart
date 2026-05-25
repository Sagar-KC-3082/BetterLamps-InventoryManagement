import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../services/toast_service.dart';
import '../models/product.dart';
import '../models/cost_price.dart';
import '../widgets/bl_components.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _totalStockCtrl = TextEditingController(text: '0');
  final _availableStockCtrl = TextEditingController(text: '0');
  final _salePriceCtrl = TextEditingController();
  final _comparePriceCtrl = TextEditingController();
  final _filamentCostCtrl = TextEditingController(text: '2600');
  final _baseWeightCtrl = TextEditingController(text: '0');
  final _shadeWeightCtrl = TextEditingController(text: '0');
  final _electricityCtrl = TextEditingController(text: '5');
  final _baseTimeCtrl = TextEditingController(text: '0');
  final _shadeTimeCtrl = TextEditingController(text: '0');
  final _otherCostCtrl = TextEditingController(text: '0');
  final _electricalAssemblyCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _nameCtrl, _skuCtrl, _descCtrl, _totalStockCtrl, _availableStockCtrl,
      _salePriceCtrl, _comparePriceCtrl, _filamentCostCtrl, _baseWeightCtrl,
      _shadeWeightCtrl, _electricityCtrl, _baseTimeCtrl, _shadeTimeCtrl,
      _otherCostCtrl, _electricalAssemblyCtrl,
    ]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl, _skuCtrl, _descCtrl, _totalStockCtrl, _availableStockCtrl,
      _salePriceCtrl, _comparePriceCtrl, _filamentCostCtrl, _baseWeightCtrl,
      _shadeWeightCtrl, _electricityCtrl, _baseTimeCtrl, _shadeTimeCtrl,
      _otherCostCtrl, _electricalAssemblyCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  CostPrice get _computedCost => CostPrice(
        filamentCostPerKg: double.tryParse(_filamentCostCtrl.text) ?? 2600,
        baseFilamentWeight: double.tryParse(_baseWeightCtrl.text) ?? 0,
        shadeFilamentWeight: double.tryParse(_shadeWeightCtrl.text) ?? 0,
        electricityCostPerHour: double.tryParse(_electricityCtrl.text) ?? 5,
        printingTimeBaseHours: double.tryParse(_baseTimeCtrl.text) ?? 0,
        printingTimeShadeHours: double.tryParse(_shadeTimeCtrl.text) ?? 0,
        otherCost: double.tryParse(_otherCostCtrl.text) ?? 0,
        electricalAssemblyCost: double.tryParse(_electricalAssemblyCtrl.text) ?? 0,
      );

  double get _sellingPrice => double.tryParse(_salePriceCtrl.text) ?? 0;
  double get _totalCost => _computedCost.totalCost;
  double get _profit => _sellingPrice - _totalCost;
  double get _margin => _sellingPrice > 0 ? (_profit / _sellingPrice * 100) : 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<DatabaseService>();
    final product = Product(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      productCode: _skuCtrl.text.trim(),
      originalPrice: double.tryParse(_comparePriceCtrl.text) ?? _sellingPrice,
      currentSellingPrice: _sellingPrice,
      costPrice: _computedCost,
      totalStock: int.tryParse(_totalStockCtrl.text) ?? 0,
      availableStock: int.tryParse(_availableStockCtrl.text) ?? 0,
    );
    await db.addProduct(product);
    if (mounted) {
      Toaster.success(context, 'Product added', message: product.name);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;

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
            // Header
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
                    'Add Product',
                    style: GoogleFonts.newsreader(
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
                    // Main edit area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormSection(
                              title: 'Basics',
                              children: [
                                BLInput(
                                  controller: _nameCtrl,
                                  label: 'Product name',
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                BLInput(controller: _skuCtrl, label: 'SKU / Product code'),
                                const SizedBox(height: 12),
                                BLInput(
                                    controller: _descCtrl,
                                    label: 'Description',
                                    maxLines: 3),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _FormSection(
                              title: 'Stock & price',
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _totalStockCtrl,
                                        label: 'Total stock',
                                        keyboardType: TextInputType.number),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _availableStockCtrl,
                                        label: 'Available',
                                        keyboardType: TextInputType.number),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _salePriceCtrl,
                                        label: 'Sale price',
                                        prefixText: 'NRS ',
                                        keyboardType: TextInputType.number,
                                        validator: (v) =>
                                            v == null || v.isEmpty ? 'Required' : null),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _comparePriceCtrl,
                                        label: 'Compare-at price',
                                        prefixText: 'NRS ',
                                        keyboardType: TextInputType.number),
                                  ),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _FormSection(
                              title: 'Cost breakdown',
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _filamentCostCtrl,
                                        label: 'Filament cost/kg',
                                        prefixText: 'NRS ',
                                        keyboardType: TextInputType.number),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _electricalAssemblyCtrl,
                                        label: 'Electrical assembly',
                                        prefixText: 'NRS ',
                                        keyboardType: TextInputType.number),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _baseWeightCtrl,
                                        label: 'Base weight (g)',
                                        keyboardType: TextInputType.number),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _shadeWeightCtrl,
                                        label: 'Shade weight (g)',
                                        keyboardType: TextInputType.number),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: BLInput(
                                        controller: _electricityCtrl,
                                        label: 'Electricity/hr',
                                        prefixText: 'NRS ',
                                        keyboardType: TextInputType.number),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _baseTimeCtrl,
                                        label: 'Base print time (hr)',
                                        keyboardType: TextInputType.number),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: BLInput(
                                        controller: _shadeTimeCtrl,
                                        label: 'Shade print time (hr)',
                                        keyboardType: TextInputType.number),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                BLInput(
                                    controller: _otherCostCtrl,
                                    label: 'Other costs',
                                    prefixText: 'NRS ',
                                    keyboardType: TextInputType.number),
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
                            // Live preview
                            BLSectionCard(
                              title: 'Cost preview',
                              child: Column(
                                children: [
                                  _PreviewRow('Filament (base)', _computedCost.baseFilamentCost, c),
                                  _PreviewRow('Filament (shade)', _computedCost.shadeFilamentCost, c),
                                  _PreviewRow('Electrical', _computedCost.electricalAssemblyCost, c),
                                  _PreviewRow('Electricity', _computedCost.electricityCost, c),
                                  _PreviewRow('Other', _computedCost.otherCost, c),
                                  Divider(color: c.rule, height: 16),
                                  _PreviewRow('Total cost', _totalCost, c, bold: true),
                                  _PreviewRow('Selling price', _sellingPrice, c, bold: true),
                                  Divider(color: c.rule, height: 16),
                                  _PreviewRow('Profit', _profit, c, bold: true, colorize: true),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Margin',
                                          style: GoogleFonts.interTight(fontSize: 13, color: c.muted)),
                                      Text(
                                        '${_margin.toStringAsFixed(1)}%',
                                        style: GoogleFonts.interTight(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _margin > 30 ? c.moss : (_margin > 0 ? c.gold : c.berry),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Aside tip
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: c.coralSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(left: BorderSide(color: c.coral, width: 2)),
                              ),
                              child: Text(
                                'Pro tip: Aim for 35–45% margin on standard lamps. Higher for custom designs.',
                                style: GoogleFonts.newsreader(
                                    color: c.coral2, letterSpacing: -0.2),
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
            // Sticky footer
            Container(
              decoration: BoxDecoration(
                color: c.bg2,
                border: Border(top: BorderSide(color: c.rule, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                children: [
                  Text(
                    '⌘S save  ·  esc discard',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10, color: c.muted, letterSpacing: 0.5),
                  ),
                  const Spacer(),
                  BLButton(
                    label: 'Cancel',
                    kind: BLButtonKind.ghost,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  BLButton(
                    label: 'Add Product',
                    kind: BLButtonKind.primary,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Text(
          title,
          style: GoogleFonts.newsreader(
              fontSize: 16, fontWeight: FontWeight.w500,
              color: c.ink, letterSpacing: -0.27),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.bg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.rule, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final double value;
  final BLColors c;
  final bool bold;
  final bool colorize;

  const _PreviewRow(this.label, this.value, this.c,
      {this.bold = false, this.colorize = false});

  @override
  Widget build(BuildContext context) {
    final textColor = colorize
        ? (value >= 0 ? c.moss : c.berry)
        : (bold ? c.ink : c.ink2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.interTight(
                  fontSize: 13, color: c.muted, letterSpacing: -0.07)),
          Text('NRS ${value.toStringAsFixed(0)}',
              style: GoogleFonts.newsreader(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                  letterSpacing: -0.3)),
        ],
      ),
    );
  }
}
