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
                  return ElevatedButton.icon(
                    onPressed: db.products.isEmpty
                        ? () => _showNoProductsDialog(context)
                        : () => showSaleDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Record Sale'),
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
                  _StatCard(
                    label: 'Total Sales',
                    value: db.totalSalesCount.toString(),
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    label: 'Revenue',
                    value: 'NRS ${db.totalSalesAmount.toStringAsFixed(0)}',
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    label: 'Avg. Sale',
                    value: db.sales.isEmpty
                        ? 'NRS 0'
                        : 'NRS ${(db.totalSalesAmount / db.sales.length).toStringAsFixed(0)}',
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: context.borderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 56),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Product',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
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
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 120,
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF737373),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: db.sales.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: context.borderColor,
                          ),
                          itemBuilder: (context, index) {
                            final sale = db.sales[index];
                            final product = db.getProductById(sale.productId);
                            return _SaleRow(sale: sale, product: product);
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

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
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

  const _SaleRow({required this.sale, this.product});

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
              _buildProductImage(),
              const SizedBox(width: 16),
              // Product
              Expanded(
                flex: 2,
                child: Text(
                  widget.product?.name ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              // Customer
              Expanded(
                flex: 2,
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
              // Date
              Expanded(
                child: Text(
                  DateFormat('MMM d, yyyy').format(widget.sale.saleDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ),
              // Amount
              SizedBox(
                width: 120,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.successBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'NRS ${widget.sale.price.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.successColor,
                    ),
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
                          Icon(Icons.edit_outlined,
                              size: 18, color: context.textSecondary),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: context.errorColor),
                          const SizedBox(width: 12),
                          Text('Delete',
                              style: TextStyle(color: context.errorColor)),
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


