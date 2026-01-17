import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'sale_form_dialog.dart';

void showSaleDetailsSheet(BuildContext context, Sale sale, Product? product) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
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
        child: SaleDetailsSheet(sale: sale, product: product),
      );
    },
  );
}

class SaleDetailsSheet extends StatelessWidget {
  final Sale sale;
  final Product? product;

  const SaleDetailsSheet({
    super.key,
    required this.sale,
    required this.product,
  });

  void _deleteSale(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: Text('Delete sale to "${sale.customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteSale(sale.id);
              // Close dialog then sheet indicating removal?
              // Actually if we delete, the sheet should close.
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
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
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.5;
    
    // Calculate profit if product data exists
    double? profit;
    double? margin;
    if (product != null) {
      profit = sale.price - product!.costPrice.totalCost;
      margin = sale.price > 0 ? (profit / sale.price * 100) : 0;
    }

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
                          Icons.receipt_long_outlined,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Sale Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                           Navigator.pop(context);
                           showSaleDialog(context, sale);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        color: context.textSecondary,
                        tooltip: 'Edit Sale',
                      ),
                      const SizedBox(width: 8),
                       IconButton(
                        onPressed: () => _deleteSale(context),
                        icon: Icon(Icons.delete_outline, color: context.errorColor),
                        tooltip: 'Delete Sale',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: context.textSecondary),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Card
                    _SectionHeader('Product Sold'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.02)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: context.surfaceColor,
                              border: Border.all(color: context.borderColor),
                            ),
                            child: product != null && product!.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(product!.images.first),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.image_not_supported_outlined, 
                                    color: context.textSecondary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?.name ?? 'Unknown Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (product?.productCode.isNotEmpty ?? false)
                                  Text(
                                    product!.productCode,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.successBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Sold',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Two Column Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader('Customer'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.borderColor),
                                ),
                                child: Column(
                                  children: [
                                    _InfoRow(
                                      icon: Icons.person_outline,
                                      label: 'Name',
                                      value: sale.customer.name,
                                    ),
                                    _InfoRow(
                                      icon: Icons.phone_outlined,
                                      label: 'Phone',
                                      value: sale.customer.phone,
                                    ),
                                    if (sale.customer.instaId?.isNotEmpty ?? false)
                                      _InfoRow(
                                        icon: Icons.camera_alt_outlined,
                                        label: 'Insta ID',
                                        value: sale.customer.instaId!,
                                      ),
                                    _InfoRow(
                                      icon: Icons.location_on_outlined,
                                      label: 'Address',
                                      value: sale.customer.address,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Transaction Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader('Transaction'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.borderColor),
                                ),
                                child: Column(
                                  children: [
                                    _InfoRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Date',
                                      value: DateFormat('MMM d, yyyy')
                                          .format(sale.saleDate),
                                    ),
                                    _InfoRow(
                                      icon: Icons.sell_outlined,
                                      label: 'Sale Price',
                                      value: 'NRS ${sale.price.toStringAsFixed(0)}',
                                      isBold: true,
                                    ),
                                    _InfoRow(
                                      icon: Icons.account_balance_wallet_outlined,
                                      label: 'Payment Settled By',
                                      value: sale.accountSettledIn,
                                    ),
                                    if (sale.source?.isNotEmpty ?? false)
                                      _InfoRow(
                                        icon: Icons.campaign_outlined,
                                        label: 'Source',
                                        value: sale.source!,
                                      ),
                                    _InfoRow(
                                      icon: sale.isFollowedUp ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                                      label: 'Followed Up',
                                      value: sale.isFollowedUp ? 'Yes' : 'No',
                                    ),
                                    if (sale.notes?.isNotEmpty ?? false)
                                      _InfoRow(
                                        icon: Icons.sticky_note_2_outlined,
                                        label: 'Additional Notes',
                                        value: sale.notes!,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Financial / Profit Summary
                    if (profit != null) ...[
                      const SizedBox(height: 32),
                      _SectionHeader('Financial Summary'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                           gradient: LinearGradient(
                            colors: [
                              (profit >= 0 ? context.successBgColor : context.errorBgColor).withOpacity(0.5),
                              (profit >= 0 ? context.successBgColor : context.errorBgColor).withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (profit >= 0 ? context.successColor : context.errorColor).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (profit >= 0 ? context.successColor : context.errorColor).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                profit >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: profit >= 0 ? context.successColor : context.errorColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profit >= 0 ? 'Estimated Profit' : 'Loss',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NRS ${profit.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: profit >= 0 ? context.successColor : context.errorColor,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Margin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${margin!.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: profit >= 0 ? context.successColor : context.errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimary,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
