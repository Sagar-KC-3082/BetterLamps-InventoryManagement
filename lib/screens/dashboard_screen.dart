import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../models/cost_price.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_form_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<DatabaseService>(
      builder: (context, db, child) {
        final allProducts = List<Product>.from(db.products);
        allProducts.sort((a, b) => a.createdDate.compareTo(b.createdDate));
        
        final totalProducts = allProducts.length;
        final totalStock = allProducts.fold(
          0,
          (sum, p) => sum + p.availableStock,
        );
        final lowStockProducts = allProducts
            .where((p) => p.isLowStock || p.isOutOfStock)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Status',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real-time overview of your 3D printed lamp stock.',
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.download_outlined,
                      size: 18,
                      color: context.textPrimary,
                    ),
                    label: Text(
                      'Export Report',
                      style: TextStyle(color: context.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: context.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: context.brandShadow,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showProductDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text('Add New Item'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),



              // Stats Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'TOTAL PRODUCTS',
                          value: totalProducts.toString(),
                          subtitle: 'Unique designs',
                          icon: Icons.category_outlined,
                          backgroundImage: 'assets/images/4046534.jpg',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _StatCard(
                          title: 'AVAILABLE STOCK',
                          value: totalStock.toString(),
                          subtitle: 'Ready to ship units',
                          icon: Icons.inventory_2_outlined,
                          backgroundImage: 'assets/images/5557528.jpg',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _StatCard(
                          title: 'LOW STOCK ALERTS',
                          value: lowStockProducts.length.toString(),
                          subtitle: 'Require printing',
                          icon: Icons.warning_amber_rounded,
                          isAlert: true,
                          alertColor: context.primaryColor,
                          backgroundImage: 'assets/images/6379114.jpg',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),

              // Critical Stock Levels Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Critical Stock Levels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: context.primaryColor),
                    child: const Row(
                      children: [
                        Text(
                          'View All Inventory',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Table Content
              db.products.isEmpty
                  ? _EmptyState()
                  : Container(
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                        boxShadow: context.subtleShadow,
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: context.surfaceColor.withOpacity(0.5),
                              border: Border(
                                bottom: BorderSide(
                                  color: context.borderColor,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _HeaderCell('Product Name'),
                                ),
                                Expanded(flex: 2, child: _HeaderCell('SKU')),
                                Expanded(
                                  flex: 2,
                                  child: _HeaderCell('Stock Level'),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _HeaderCell(
                                    'Status',
                                    align: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  width: 48,
                                  child: _HeaderCell(
                                    'Action',
                                    align: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Table Rows
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: allProducts.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: context.borderColor,
                            ),
                            itemBuilder: (context, index) {
                              return _ProductRow(
                                product: allProducts[index],
                                onEdit: () => _showProductDialog(
                                  context,
                                  db.products[index],
                                ),
                                onDelete: () => _deleteProduct(
                                  context,
                                  db.products[index],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
      },
    );
  }

  void _showProductDialog(BuildContext context, [Product? product]) {
    showProductDialog(context, product);
  }

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteProduct(product.id);
              Navigator.pop(context);
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
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final TextAlign align;

  const _HeaderCell(this.label, {this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.textSecondary.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isAlert;
  final Color? alertColor;
  final String? backgroundImage;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isAlert = false,
    this.alertColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        alertColor ?? (isAlert ? context.errorColor : context.primaryColor);

    return Container(
      // Height fixed or padding? Sales didn't have fixed height but container with padding
      height: 160, // Making it slightly taller or same as Sales (120)?
      // Sales used 120. Dashboard previously relied on padding.
      // Let's set a fixed height to ensure image covers properly or keep it flexible.
      // Sales stat card has height: 120. Let's use 120 for consistency.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.subtleShadow,
      ),
      child: Stack(
        children: [
          if (backgroundImage != null)
             Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    Icon(
                      isAlert ? Icons.warning_rounded : icon,
                      size: 20,
                      color: accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
              ],
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: context.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(color: context.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to the catalog to start tracking inventory.',
              style: TextStyle(
                color: context.textSecondary.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final stockPercent = p.totalStock > 0
        ? (p.availableStock / p.totalStock)
        : 0.0;

    // Status Logic
    Color statusColor;
    Color statusBg;
    String statusText;

    if (p.totalStock == 0) {
      statusColor = context.textSecondary;
      statusBg = context.textSecondary.withOpacity(0.1);
      statusText = 'No Stock';
    } else if (stockPercent <= 0.25) {
      statusColor = context.errorColor;
      statusBg = context.errorBgColor;
      statusText = 'Critical';
    } else if (stockPercent <= 0.45) {
      statusColor = context.warningColor;
      statusBg = context.warningBgColor;
      statusText = 'Low';
    } else {
      statusColor = context.successColor;
      statusBg = context.successBgColor;
      statusText = 'Healthy';
    }

    return MouseRegion(
      onEnter: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isHovered = true);
      }),
      onExit: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isHovered = false);
      }),
      child: Container(
        color: _isHovered ? context.surfaceColor : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Product Name & Image
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: p.images.isNotEmpty
                        ? Image.memory(
                            base64Decode(p.images.first),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: context.surfaceColor,
                            child: Icon(
                              Icons.lightbulb_outline,
                              size: 24,
                              color: context.textSecondary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      p.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // SKU
            Expanded(
              flex: 2,
              child: Text(
                p.productCode.isNotEmpty ? p.productCode : '-',
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
            ),
            // Stock Level (Bar)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${p.availableStock} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: '/ ${p.totalStock}',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: stockPercent.clamp(0.0, 1.0),
                      backgroundColor: context.surfaceColor,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            // Status
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action
            SizedBox(
              width: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: context.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  onSelected: (v) =>
                      v == 'edit' ? widget.onEdit() : widget.onDelete(),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
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


