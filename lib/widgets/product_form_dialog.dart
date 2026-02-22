import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/cost_price.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

void showProductDialog(BuildContext context, [Product? product]) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    // Animation from right (1.0, 0.0)
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: ProductFormDialog(product: product),
      );
    },
  );
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _productCodeController;
  late TextEditingController _originalPriceController;
  late TextEditingController _currentSellingPriceController;
  late TextEditingController _shadeFilamentWeightController;
  late TextEditingController _baseFilamentWeightController;
  late TextEditingController _filamentCostPerKgController;
  late TextEditingController _electricalAssemblyCostController;
  late TextEditingController _printingTimeShadeController;
  late TextEditingController _printingTimeBaseController;
  late TextEditingController _electricityRateController;
  late TextEditingController _otherCostController;
  late TextEditingController _totalStockController;
  late TextEditingController _availableStockController;
  bool _sameAsOriginalPrice = true;
  List<String> _images = [];

  double get _computedTotalCost {
    final shadeWeight = _parseDouble(_shadeFilamentWeightController.text);
    final baseWeight = _parseDouble(_baseFilamentWeightController.text);
    final costPerKg = _parseDouble(_filamentCostPerKgController.text);

    final shadeCost = (shadeWeight / 1000) * costPerKg;
    final baseCost = (baseWeight / 1000) * costPerKg;

    final shadeTime = _parseDouble(_printingTimeShadeController.text);
    final baseTime = _parseDouble(_printingTimeBaseController.text);
    final elecRate = _parseDouble(_electricityRateController.text);
    final elecCost = (shadeTime + baseTime) * elecRate;

    return shadeCost +
        baseCost +
        _parseDouble(_electricalAssemblyCostController.text) +
        elecCost +
        _parseDouble(_otherCostController.text);
  }

  double _parseDouble(String value) => double.tryParse(value) ?? 0;

  int _parseInt(String value) => int.tryParse(value) ?? 0;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final costPrice = product?.costPrice ?? const CostPrice.empty();

    _nameController = TextEditingController(text: product?.name ?? '');
    _productCodeController = TextEditingController(
      text: product?.productCode ?? '',
    );
    _originalPriceController = TextEditingController(
      text: product?.originalPrice.toString() ?? '',
    );
    _currentSellingPriceController = TextEditingController(
      text: product?.currentSellingPrice.toString() ?? '',
    );
    _shadeFilamentWeightController = TextEditingController(
      text: costPrice.shadeFilamentWeight > 0
          ? costPrice.shadeFilamentWeight.toString()
          : '',
    );
    _baseFilamentWeightController = TextEditingController(
      text: costPrice.baseFilamentWeight > 0
          ? costPrice.baseFilamentWeight.toString()
          : '60', // Default 60 if missing
    );
    _filamentCostPerKgController = TextEditingController(
      text: costPrice.filamentCostPerKg > 0
          ? costPrice.filamentCostPerKg.toString()
          : '2600', // Default 2600
    );
    _electricalAssemblyCostController = TextEditingController(
      text: costPrice.electricalAssemblyCost > 0
          ? costPrice.electricalAssemblyCost.toString()
          : '',
    );
    _printingTimeShadeController = TextEditingController(
      text: costPrice.printingTimeShadeHours > 0
          ? costPrice.printingTimeShadeHours.toString()
          : '',
    );
    _printingTimeBaseController = TextEditingController(
      text: costPrice.printingTimeBaseHours > 0
          ? costPrice.printingTimeBaseHours.toString()
          : '2', // Default 2 if missing
    );
    _electricityRateController = TextEditingController(
      text: costPrice.electricityCostPerHour > 0
          ? costPrice.electricityCostPerHour.toString()
          : '5', // Default 5
    );
    _otherCostController = TextEditingController(
      text: costPrice.otherCost > 0 ? costPrice.otherCost.toString() : '',
    );
    _totalStockController = TextEditingController(
      text: product != null ? product.totalStock.toString() : '',
    );
    _availableStockController = TextEditingController(
      text: product != null ? product.availableStock.toString() : '',
    );
    _images = List.from(product?.images ?? []);

    if (product != null) {
      _sameAsOriginalPrice =
          product.currentSellingPrice == product.originalPrice;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productCodeController.dispose();
    _originalPriceController.dispose();
    _currentSellingPriceController.dispose();
    _shadeFilamentWeightController.dispose();
    _baseFilamentWeightController.dispose();
    _filamentCostPerKgController.dispose();
    _electricalAssemblyCostController.dispose();
    _printingTimeShadeController.dispose();
    _printingTimeBaseController.dispose();
    _electricityRateController.dispose();
    _otherCostController.dispose();
    _totalStockController.dispose();
    _availableStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedImages.isNotEmpty) {
        for (final image in pickedImages) {
          final bytes = await image.readAsBytes();
          setState(() => _images.add(base64Encode(bytes)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    final size = MediaQuery.of(context).size;
    final width = size.width * 0.5;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.cardColor,
          border: Border(left: BorderSide(color: context.borderColor)),
          boxShadow: context.subtleShadow,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Edit Product' : 'Add New Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSecondary),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images
                      SizedBox(
                        height: 100,
                        child: Row(
                          children: [
                            _AddImageCard(onTap: _pickImages),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _images.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No images',
                                        style: TextStyle(
                                          color: context.textSecondary
                                              .withOpacity(0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _images.length,
                                      itemBuilder: (context, index) {
                                        return _ImageThumbnail(
                                          imageBase64: _images[index],
                                          onRemove: () => setState(
                                            () => _images.removeAt(index),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Basic Info
                      const _SectionLabel('Basic Info'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _productCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Product Code',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      // Stock Info
                      const _SectionLabel('Stock Information'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalStockController,
                              decoration: const InputDecoration(
                                labelText: 'Total Stock',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _availableStockController,
                              decoration: const InputDecoration(
                                labelText: 'Available Stock',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              validator: (v) {
                                final available = _parseInt(v ?? '0');
                                final total = _parseInt(
                                  _totalStockController.text,
                                );
                                if (available > total) {
                                  return 'Cannot exceed total';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Cost Breakdown
                      const _SectionLabel('Cost Breakdown'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _filamentCostPerKgController,
                              decoration: const InputDecoration(
                                labelText: 'Filament Cost / kg',
                                prefixText: 'NRS ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _shadeFilamentWeightController,
                              decoration: const InputDecoration(
                                labelText: 'Shade Weight (g)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _baseFilamentWeightController,
                              decoration: const InputDecoration(
                                labelText: 'Base Weight (g)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _electricityRateController,
                              decoration: const InputDecoration(
                                labelText: 'Electricity Rate / hr',
                                prefixText: 'NRS ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _printingTimeShadeController,
                              decoration: const InputDecoration(
                                labelText: 'Shade Time (hr)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _printingTimeBaseController,
                              decoration: const InputDecoration(
                                labelText: 'Base Time (hr)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _electricalAssemblyCostController,
                              decoration: const InputDecoration(
                                labelText: 'Electrical',
                                prefixText: 'NRS ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _otherCostController,
                              decoration: const InputDecoration(
                                labelText: 'Other',
                                prefixText: 'NRS ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Spacer(),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context.successBgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.successColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Total: ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.successColor,
                                    ),
                                  ),
                                  Text(
                                    'NRS ${_computedTotalCost.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Selling Price
                      const _SectionLabel('Pricing'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _originalPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price',
                                prefixText: 'NRS ',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (_sameAsOriginalPrice) {
                                  _currentSellingPriceController.text = value;
                                }
                                setState(() {});
                              },
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _currentSellingPriceController,
                              enabled: !_sameAsOriginalPrice,
                              decoration: InputDecoration(
                                labelText: 'Discount Price',
                                prefixText: 'NRS ',
                                filled: _sameAsOriginalPrice,
                                fillColor: _sameAsOriginalPrice 
                                    ? context.isDarkMode 
                                        ? Colors.white.withOpacity(0.05) 
                                        : Colors.grey.withOpacity(0.1)
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: _sameAsOriginalPrice,
                              onChanged: (value) {
                                setState(() {
                                  _sameAsOriginalPrice = value ?? true;
                                  if (_sameAsOriginalPrice) {
                                    _currentSellingPriceController.text =
                                        _originalPriceController.text;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No Discount',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Profit Preview
                      if (_computedTotalCost > 0 &&
                          _parseDouble(_originalPriceController.text) > 0)
                        _ProfitPreview(
                          sellingPrice: _parseDouble(
                            _sameAsOriginalPrice
                                ? _originalPriceController.text
                                : _currentSellingPriceController.text,
                          ),
                          totalCost: _computedTotalCost,
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.borderColor)),
                color: context.cardColor,
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      side: BorderSide(color: context.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: context.textPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: context.brandShadow,
                        gradient: context.primaryGradient,
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent, // Shadow handled by container
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isEditing ? Icons.save_outlined : Icons.add, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Save Changes' : 'Add Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final db = context.read<DatabaseService>();
    final originalPrice = double.parse(_originalPriceController.text);
    final currentSellingPrice = _sameAsOriginalPrice
        ? originalPrice
        : double.parse(_currentSellingPriceController.text);

    final costPrice = CostPrice(
      shadeFilamentWeight: _parseDouble(_shadeFilamentWeightController.text),
      baseFilamentWeight: _parseDouble(_baseFilamentWeightController.text),
      filamentCostPerKg: _parseDouble(_filamentCostPerKgController.text),
      electricalAssemblyCost: _parseDouble(
        _electricalAssemblyCostController.text,
      ),
      printingTimeShadeHours: _parseDouble(_printingTimeShadeController.text),
      printingTimeBaseHours: _parseDouble(_printingTimeBaseController.text),
      electricityCostPerHour: _parseDouble(_electricityRateController.text),
      otherCost: _parseDouble(_otherCostController.text),
    );

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      productCode: _productCodeController.text.trim(),
      createdDate: widget.product?.createdDate ?? DateTime.now(),
      originalPrice: originalPrice,
      currentSellingPrice: currentSellingPrice,
      images: _images,
      costPrice: costPrice,
      totalStock: _parseInt(_totalStockController.text),
      availableStock: _parseInt(_availableStockController.text),
    );

    if (widget.product != null) {
      db.updateProduct(product);
    } else {
      db.addProduct(product);
    }

    Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: context.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _AddImageCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: context.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatefulWidget {
  final String imageBase64;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    required this.imageBase64,
    required this.onRemove,
    super.key,
  });

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail> {
  late Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = base64Decode(widget.imageBase64);
  }

  @override
  void didUpdateWidget(covariant _ImageThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageBase64 != oldWidget.imageBase64) {
      _imageBytes = base64Decode(widget.imageBase64);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_imageBytes, fit: BoxFit.cover),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.errorColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitPreview extends StatelessWidget {
  final double sellingPrice;
  final double totalCost;

  const _ProfitPreview({required this.sellingPrice, required this.totalCost});

  @override
  Widget build(BuildContext context) {
    final profit = sellingPrice - totalCost;
    final profitMargin = sellingPrice > 0 ? (profit / sellingPrice * 100) : 0;
    final isLoss = profit < 0;
    final color = isLoss ? context.errorColor : context.successColor;
    final bgColor = isLoss ? context.errorBgColor : context.successBgColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isLoss ? Icons.trending_down : Icons.trending_up,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoss ? 'Loss' : 'Profit',
                  style: TextStyle(fontSize: 12, color: color),
                ),
                Text(
                  'NRS ${profit.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${profitMargin.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
