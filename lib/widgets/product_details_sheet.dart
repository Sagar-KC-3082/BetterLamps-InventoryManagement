import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cost_price.dart' as cost_price;
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'product_form_dialog.dart';

void showProductDetailsSheet(BuildContext context, Product product) {
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
        child: ProductDetailsSheet(product: product),
      );
    },
  );
}

class ProductDetailsSheet extends StatelessWidget {
  final Product product;

  const ProductDetailsSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
                          Icons.inventory_2_outlined,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Product Details',
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
                          // Close detail sheet then open edit dialog
                          Navigator.pop(context); 
                          showProductDialog(context, product);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        color: context.textSecondary,
                        tooltip: 'Edit Product',
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
                    // Images Section
                    if (product.images.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: context.borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.memory(
                                  base64Decode(product.images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: context.textSecondary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No images available',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Basic Info
                    _SectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.02)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        children: [
                          _DetailRow('Product Name', product.name),
                          _DetailRow('Product Code', product.productCode),
                          _DetailRow('Total Stock', product.totalStock.toString()),
                          _DetailRow(
                            'Available Stock', 
                            product.availableStock.toString(),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pricing & Finance
                    _SectionHeader('Pricing & Costs'),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pricing column
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _PriceRow(
                                  'Regular Price', 
                                  product.originalPrice,
                                ),
                                if (product.currentSellingPrice != product.originalPrice)
                                  _PriceRow(
                                    'Discount Price', 
                                    product.currentSellingPrice,
                                    isHighlight: true,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Cost Breakdown Column
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cost Analysis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _FilamentCostRow(costPrice: product.costPrice),
                                _PriceRow(
                                  'Electronics',
                                  product.costPrice.electricalAssemblyCost,
                                  icon: Icons.cable,
                                ),
                                _ElectricityCostRow(costPrice: product.costPrice),
                                _PriceRow(
                                  'Other',
                                  product.costPrice.otherCost,
                                  icon: Icons.work_outline,
                                ),
                                const Divider(height: 24),
                                _PriceRow(
                                  'Total Cost', 
                                  product.costPrice.totalCost,
                                  isBold: true,
                                  icon: Icons.functions,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Profitability Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.successBgColor.withOpacity(0.5),
                            context.successBgColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.successColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: context.successColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Profit per Unit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NRS ${(product.currentSellingPrice - product.costPrice.totalCost).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.successColor,
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
                                '${((product.currentSellingPrice - product.costPrice.totalCost) / product.currentSellingPrice * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: context.successColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.textPrimary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final bool isHighlight;
  final IconData? icon;

  const _PriceRow(this.label, this.amount, {
    this.isBold = false,
    this.isHighlight = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.textSecondary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            'NRS ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isHighlight ? context.primaryColor : context.textPrimary,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


class _FilamentCostRow extends StatefulWidget {
  final cost_price.CostPrice costPrice;

  const _FilamentCostRow({required this.costPrice});

  @override
  State<_FilamentCostRow> createState() => _FilamentCostRowState();
}

class _FilamentCostRowState extends State<_FilamentCostRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final shadeCost = widget.costPrice.shadeFilamentCost;
    final baseCost = widget.costPrice.baseFilamentCost;
    final totalFilamentCost = shadeCost + baseCost;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filament Cost',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 14,
                      color: context.textSecondary,
                    ),
                  ],
                ),
                Text(
                  'NRS ${totalFilamentCost.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Column(
              children: [
                _SubDetailRow(
                  'Shade (${widget.costPrice.shadeFilamentWeight.toStringAsFixed(0)}g)',
                  shadeCost,
                ),
                _SubDetailRow(
                  'Base (${widget.costPrice.baseFilamentWeight.toStringAsFixed(0)}g)',
                  baseCost,
                ),
                _SubDetailRow(
                  'Rate',
                  widget.costPrice.filamentCostPerKg,
                  isCurrency: true,
                  prefix: '@ NRS ',
                  suffix: '/kg',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SubDetailRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isCurrency;
  final String prefix;
  final String suffix;

  const _SubDetailRow(
    this.label,
    this.amount, {
    this.isCurrency = true,
    this.prefix = 'NRS ',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          Text(
            '$prefix${amount.toStringAsFixed(0)}$suffix',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  }


class _ElectricityCostRow extends StatefulWidget {
  final cost_price.CostPrice costPrice;

  const _ElectricityCostRow({required this.costPrice});

  @override
  State<_ElectricityCostRow> createState() => _ElectricityCostRowState();
}

class _ElectricityCostRowState extends State<_ElectricityCostRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final shadeTime = widget.costPrice.printingTimeShadeHours;
    final baseTime = widget.costPrice.printingTimeBaseHours;
    final rate = widget.costPrice.electricityCostPerHour;
    final shadeCost = shadeTime * rate;
    final baseCost = baseTime * rate;
    final totalCost = widget.costPrice.electricityCost;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_outlined,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Power Cost',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 14,
                      color: context.textSecondary,
                    ),
                  ],
                ),
                Text(
                  'NRS ${totalCost.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Column(
              children: [
                _SubDetailRow(
                  'Shade (${shadeTime.toStringAsFixed(1)}hr)',
                  shadeCost,
                ),
                _SubDetailRow(
                  'Base (${baseTime.toStringAsFixed(1)}hr)',
                  baseCost,
                ),
                _SubDetailRow(
                  'Rate',
                  rate,
                  isCurrency: true,
                  prefix: '@ NRS ',
                  suffix: '/hr',
                ),
              ],
            ),
          ),
      ],
    );
  }
}
