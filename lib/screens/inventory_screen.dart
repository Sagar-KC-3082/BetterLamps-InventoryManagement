import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_details_sheet.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseService>(
      builder: (context, db, child) {
        final products = db.products;
        // Sort by creation date by default or name? 
        // User didn't specify sort, but usually newest first is good or alphabetical.
        // Dashboard does createdDate. Let's do that.
        final sortedProducts = List<Product>.from(products)
          ..sort((a, b) => b.createdDate.compareTo(a.createdDate)); // Newest first

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
                        'Product Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your product catalog',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showProductDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New Product'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Product List
              Expanded(
                child: products.isEmpty
                    ? _EmptyState()
                    : Container(
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          children: [
                            // Table Header
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
                                  const SizedBox(width: 56), // Space for Image
                                  Expanded(
                                    flex: 3,
                                    child: _HeaderCell('Product Name'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _HeaderCell('SKU'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _HeaderCell('Price'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _HeaderCell('Stock'),
                                  ),
                                  // Actions
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            // List
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: sortedProducts.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: context.borderColor,
                                ),
                                itemBuilder: (context, index) {
                                  return _ProductListRow(
                                    product: sortedProducts[index],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Add New Product" to get started',
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListRow extends StatefulWidget {
  final Product product;

  const _ProductListRow({required this.product});

  @override
  State<_ProductListRow> createState() => _ProductListRowState();
}

class _ProductListRowState extends State<_ProductListRow> {
  bool _isHovered = false;
  bool _isExpanded = false;

  Widget _buildProductImage() {
    if (widget.product.images.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            base64Decode(widget.product.images.first),
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

  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${widget.product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteProduct(widget.product.id);
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => showProductDetailsSheet(context, widget.product),
        child: Container(
          color: _isHovered
              ? (context.isDarkMode
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.01))
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildProductImage(),
              const SizedBox(width: 16),
              
              // Name
              Expanded(
                flex: 3,
                child: Text(
                  widget.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              
              // SKU
              Expanded(
                flex: 2,
                child: Text(
                  widget.product.productCode.isEmpty ? '-' : widget.product.productCode,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ),

              // Price
              Expanded(
                flex: 2,
                child: Text(
                  'NRS ${widget.product.currentSellingPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Stock
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(
                      '${widget.product.availableStock}',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.product.availableStock < 5 
                            ? context.errorColor 
                            : context.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                     Text(
                      ' / ${widget.product.totalStock}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              SizedBox(
                width: 40,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: context.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      showProductDialog(context, widget.product);
                    } else if (value == 'delete') {
                      _deleteProduct(context);
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
}
