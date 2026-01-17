import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sale_form_dialog.dart';
import '../widgets/sale_details_sheet.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your sales and customers',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              Consumer<DatabaseService>(
                builder: (context, db, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ), // Premium look
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: db.products.isEmpty
                            ? () => _showNoProductsDialog(context)
                            : () => showSaleDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Record Sale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Stats
          Consumer<DatabaseService>(
            builder: (context, db, child) {
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Sales',
                      value: db.totalSalesCount.toString(),
                      color: const Color(0xFF3B82F6), // Blue
                      backgroundImage: 'assets/images/4046534.jpg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Revenue',
                      value: 'NRS ${db.totalSalesAmount.toStringAsFixed(0)}',
                      color: const Color(0xFF10B981), // Green
                      backgroundImage: 'assets/images/5557528.jpg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Total Profit',
                      value: 'NRS ${db.totalProfit.toStringAsFixed(0)}',
                      color: const Color(0xFF8B5CF6), // Purple
                      backgroundImage: 'assets/images/6379114.jpg',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          // Sales List
          Expanded(
            child: Consumer<DatabaseService>(
              builder: (context, db, child) {
                if (db.sales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 48,
                          color: context.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sales yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          db.products.isEmpty
                              ? 'Add products first'
                              : 'Record your first sale',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: context.borderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                'S.N.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 56),
                                child: Text(
                                  'Product',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Source',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Text(
                                'Gross Profit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                            // Actions space matches row popup
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: db.sales.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: context.borderColor),
                          itemBuilder: (context, index) {
                            final sale = db.sales[index];
                            final product = db.getProductById(sale.productId);
                            return _SaleRow(
                              sale: sale,
                              product: product,
                              index: index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNoProductsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Products'),
        content: const Text('Add products first before recording a sale.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? backgroundImage;

  const _StatCard({
    required this.label,
    required this.value,
    this.color = const Color(0xFF3B82F6),
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
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
                opacity: 0.15, // Low opacity for background
                child: Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up, 
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatefulWidget {
  final Sale sale;
  final Product? product;
  final int index;

  const _SaleRow({required this.sale, this.product, required this.index});

  @override
  State<_SaleRow> createState() => _SaleRowState();
}

class _SaleRowState extends State<_SaleRow> {
  bool _isHovered = false;

  Widget _buildProductImage() {
    if (widget.product != null && widget.product!.images.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            base64Decode(widget.product!.images.first),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return _defaultImage();
      }
    }
    return _defaultImage();
  }

  Widget _defaultImage() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.lightbulb_outline,
        color: context.textSecondary.withOpacity(0.3),
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profit =
        widget.sale.price - (widget.product?.costPrice.totalCost ?? 0);

    return MouseRegion(
      onEnter: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isHovered = true);
      }),
      onExit: (_) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isHovered = false);
      }),
      child: InkWell(
        onTap: () => showSaleDetailsSheet(context, widget.sale, widget.product),
        child: Container(
          color: _isHovered
              ? (context.isDarkMode
                    ? Colors.white.withOpacity(0.02)
                    : Colors.black.withOpacity(0.01))
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildProductImage(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.product?.name ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Customer
              // Customer
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sale.customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textPrimary,
                      ),
                    ),
                    if (widget.sale.customer.phone.isNotEmpty)
                      Text(
                        widget.sale.customer.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Source
              Expanded(
                flex: 1,
                child: Text(
                  widget.sale.source ?? '-',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Date
              Expanded(
                flex: 1,
                child: Text(
                  DateFormat('MMM d, yyyy').format(widget.sale.saleDate),
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
              ),

              Expanded(
                flex: 1,
                child: Text(
                  'NRS ${widget.sale.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: context.textPrimary,
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Text(
                  'NRS ${profit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: context.successColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Actions
              SizedBox(
                width: 40,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: context.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      showSaleDialog(context, widget.sale);
                    } else if (value == 'delete') {
                      _deleteSale(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: context.errorColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: context.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSale(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: Text('Delete sale to "${widget.sale.customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteSale(widget.sale.id);
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
