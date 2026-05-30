import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bl_components.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? _selectedId;

  void _openSheet(BuildContext context, Product product) {
    setState(() => _selectedId = product.id);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: _ProductDetailPanel(
            productId: product.id,
            onClose: () {
              setState(() => _selectedId = null);
              Navigator.of(ctx).pop();
            },
          ),
        );
      },
    ).then((_) => setState(() => _selectedId = null));
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Products',
            title: 'Products',
            actions: Row(
              children: [
                BLButton(
                  label: 'Add Product',
                  kind: BLButtonKind.primary,
                  leading: Icon(Icons.add, size: 14, color: c.ink),
                  onPressed: () => context.go('/products/new'),
                ),
              ],
            ),
          ),
          Divider(color: c.rule, height: 1),
          Expanded(
            child: db.products.isEmpty
                ? _EmptyState()
                : _ProductGrid(
                    products: db.products,
                    selectedId: _selectedId,
                    onSelect: (p) => _openSheet(context, p),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid
// ---------------------------------------------------------------------------

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final String? selectedId;
  final ValueChanged<Product> onSelect;

  const _ProductGrid({
    required this.products,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 240,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return _ProductCard(
          product: p,
          isSelected: selectedId == p.id,
          onTap: () => onSelect(p),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  BLStatusKind _stockKind(Product p) {
    if (p.isCriticalStock || p.isOutOfStock) return BLStatusKind.low;
    if (p.isLowStock) return BLStatusKind.warn;
    return BLStatusKind.healthy;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: c.bg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? c.coral : c.rule,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: c.coral.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area — fixed height so all cards look consistent
            SizedBox(
              height: 140,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: _ProductImage(product: product),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      BLStatusPill(
                        label: product.stockStatus,
                        kind: _stockKind(product),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.productCode.isNotEmpty ? product.productCode : '—',
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                      Text(
                        'NRS ${product.currentSellingPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.coral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _StockBar(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBar extends StatelessWidget {
  final Product product;
  const _StockBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final pct = product.totalStock > 0
        ? (product.availableStock / product.totalStock).clamp(0.0, 1.0)
        : 0.0;
    final barColor = product.isCriticalStock
        ? c.berry
        : product.isLowStock
            ? c.gold
            : c.moss;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${product.availableStock} / ${product.totalStock} units',
                style: TextStyle(fontSize: 11, color: c.muted)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 3,
            backgroundColor: c.bg3,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Product product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.images.isNotEmpty) {
      try {
        final raw = product.images.first;
        final b64 = raw.contains(',') ? raw.split(',').last : raw;
        final bytes = base64Decode(b64);
        return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity,
            errorBuilder: (_, __, ___) => _LetterAvatar(product: product));
      } catch (_) {}
    }
    return _LetterAvatar(product: product);
  }
}

class _LetterAvatar extends StatelessWidget {
  final Product product;
  const _LetterAvatar({required this.product});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Container(
      color: c.bg3,
      alignment: Alignment.center,
      child: Text(
        product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: c.coral.withOpacity(0.5)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Panel
// ---------------------------------------------------------------------------

class _ProductDetailPanel extends StatefulWidget {
  final String productId;
  final VoidCallback onClose;

  const _ProductDetailPanel({required this.productId, required this.onClose});

  @override
  State<_ProductDetailPanel> createState() => _ProductDetailPanelState();
}

class _ProductDetailPanelState extends State<_ProductDetailPanel> {
  int _imageIndex = 0;
  String? _lastProductId;

  void _deleteProduct(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${p.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteProduct(p.id);
              Navigator.pop(ctx);
              widget.onClose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Consumer<DatabaseService>(
      builder: (context, db, _) {
        final p = db.getProductById(widget.productId);
        if (p == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => widget.onClose());
          return const SizedBox.shrink();
        }
        if (_lastProductId != p.id) {
          _lastProductId = p.id;
          _imageIndex = 0;
        }
        final cp = p.costPrice;
        return _buildContent(context, c, p, cp);
      },
    );
  }

  Widget _buildContent(BuildContext context, BLColors c, Product p, cp) {

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 560,
        height: double.infinity,
        decoration: BoxDecoration(
          color: c.bg2,
          border: Border(left: BorderSide(color: c.rule)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 32, offset: const Offset(-8, 0)),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.rule))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.ink)),
                        if (p.productCode.isNotEmpty)
                          Text(p.productCode, style: TextStyle(fontSize: 12, color: c.muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteProduct(context, p),
                    icon: Icon(Icons.delete_outline, size: 18, color: c.berry),
                    tooltip: 'Delete',
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, size: 18, color: c.muted),
                  ),
                ],
              ),
            ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  if (p.images.isNotEmpty) ...[
                    _ImageGallery(
                      images: p.images,
                      selectedIndex: _imageIndex,
                      onSelect: (i) => setState(() => _imageIndex = i),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stock
                  _SectionLabel('Stock'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _Row2Col(
                      left: _Stat(label: 'Available', value: '${p.availableStock}', color: p.isCriticalStock ? c.berry : c.moss),
                      right: _Stat(label: 'Total', value: '${p.totalStock}'),
                    ),
                    const SizedBox(height: 12),
                    _StockBar(product: p),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BLStatusPill(
                        label: p.stockStatus,
                        kind: p.isCriticalStock
                            ? BLStatusKind.low
                            : p.isLowStock
                                ? BLStatusKind.warn
                                : BLStatusKind.healthy,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Pricing
                  _SectionLabel('Pricing'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _Row2Col(
                      left: _Stat(label: 'Selling Price', value: 'NRS ${p.currentSellingPrice.toStringAsFixed(0)}', color: c.coral),
                      right: _Stat(label: 'Original Price', value: 'NRS ${p.originalPrice.toStringAsFixed(0)}'),
                    ),
                    const SizedBox(height: 12),
                    _Row2Col(
                      left: _Stat(label: 'Cost Price', value: 'NRS ${cp.totalCost.toStringAsFixed(0)}'),
                      right: _Stat(
                        label: 'Profit / unit',
                        value: 'NRS ${p.profit.toStringAsFixed(0)}',
                        color: p.profit >= 0 ? c.moss : c.berry,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Row2Col(
                      left: _Stat(label: 'Margin', value: '${p.profitMargin.toStringAsFixed(1)}%', color: p.profit >= 0 ? c.moss : c.berry),
                      right: p.hasDiscount
                          ? _Stat(label: 'Discount', value: '${p.discountPercentage.toStringAsFixed(1)}% off', color: c.gold)
                          : _Stat(label: 'Discount', value: 'None'),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Cost breakdown
                  if (cp.isNotEmpty) ...[
                    _SectionLabel('Cost Breakdown'),
                    const SizedBox(height: 8),
                    _InfoCard(children: [
                      if (cp.shadeFilamentWeight > 0)
                        _DetailRow(label: 'Shade filament', value: '${cp.shadeFilamentWeight.toStringAsFixed(0)} g  ×  NRS ${cp.filamentCostPerKg.toStringAsFixed(0)}/kg  =  NRS ${cp.shadeFilamentCost.toStringAsFixed(0)}'),
                      if (cp.baseFilamentWeight > 0)
                        _DetailRow(label: 'Base filament', value: '${cp.baseFilamentWeight.toStringAsFixed(0)} g  =  NRS ${cp.baseFilamentCost.toStringAsFixed(0)}'),
                      if (cp.electricalAssemblyCost > 0)
                        _DetailRow(label: 'Electrical assembly', value: 'NRS ${cp.electricalAssemblyCost.toStringAsFixed(0)}'),
                      if (cp.printingTimeShadeHours > 0 || cp.printingTimeBaseHours > 0)
                        _DetailRow(
                          label: 'Electricity',
                          value: '${(cp.printingTimeShadeHours + cp.printingTimeBaseHours).toStringAsFixed(1)} h  ×  NRS ${cp.electricityCostPerHour.toStringAsFixed(0)}/h  =  NRS ${cp.electricityCost.toStringAsFixed(0)}',
                        ),
                      if (cp.otherCost > 0)
                        _DetailRow(label: 'Other / packaging', value: 'NRS ${cp.otherCost.toStringAsFixed(0)}'),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Total Cost',
                        value: 'NRS ${cp.totalCost.toStringAsFixed(0)}',
                        bold: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // Metadata
                  _SectionLabel('Details'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _DetailRow(label: 'Product ID', value: p.id),
                    _DetailRow(label: 'Added on', value: DateFormat('MMM d, yyyy').format(p.createdDate)),
                    _DetailRow(label: 'Images', value: '${p.images.length} attached'),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image gallery
// ---------------------------------------------------------------------------

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ImageGallery({required this.images, required this.selectedIndex, required this.onSelect});

  Widget _decode(String raw) {
    try {
      final b64 = raw.contains(',') ? raw.split(',').last : raw;
      final bytes = base64Decode(b64);
      return Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } catch (_) {
      return const Icon(Icons.broken_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Column(
      children: [
        // Main image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: _decode(images[selectedIndex]),
          ),
        ),
        // Thumbnails
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isActive = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive ? c.coral : c.rule,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _decode(images[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Text(text.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted, letterSpacing: 0.8));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.rule),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _Row2Col extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2Col({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: left),
      const SizedBox(width: 16),
      Expanded(child: right),
    ]);
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: c.muted)),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color ?? c.ink)),
    ]);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(fontSize: 12, color: c.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 12,
                  color: c.ink,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: c.muted),
          const SizedBox(height: 16),
          Text('No products yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.ink)),
          const SizedBox(height: 6),
          Text('Add your first product to get started.', style: TextStyle(fontSize: 13, color: c.muted)),
        ],
      ),
    );
  }
}
