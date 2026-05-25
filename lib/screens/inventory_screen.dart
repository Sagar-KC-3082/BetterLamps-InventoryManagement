import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/product.dart';
import '../widgets/bl_components.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    List<Product> filtered = db.products;
    if (_statusFilter == 'Healthy') {
      filtered = db.products.where((p) => !p.isLowStock && !p.isCriticalStock && p.availableStock > 0).toList();
    } else if (_statusFilter == 'Low') {
      filtered = db.products.where((p) => p.isLowStock).toList();
    } else if (_statusFilter == 'Out of stock') {
      filtered = db.products.where((p) => p.isOutOfStock).toList();
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Inventory',
            title: 'Inventory',
            actions: Row(
              children: [
                BLButton(
                  label: 'Export',
                  kind: BLButtonKind.ghost,
                  leading: Icon(Icons.download_outlined, size: 14, color: c.ink2),
                ),
                const SizedBox(width: 8),
                BLButton(
                  label: 'Add Product',
                  kind: BLButtonKind.primary,
                  leading: Icon(Icons.add, size: 14, color: c.ink),
                  onPressed: () => context.go('/inventory/new'),
                ),
              ],
            ),
          ),
          Divider(color: c.rule, height: 1),
          Expanded(
            child: BLWorkspace(
              filterRail: BLFilterRail(
                selectedItem: _statusFilter,
                onSelect: (group, item) => setState(() => _statusFilter = item),
                groups: const [
                  BLFilterGroup(label: 'Status', items: [
                    BLFilterItem(label: 'All'),
                    BLFilterItem(label: 'Healthy'),
                    BLFilterItem(label: 'Low'),
                    BLFilterItem(label: 'Out of stock'),
                  ]),
                  BLFilterGroup(label: 'Saved Views', items: [
                    BLFilterItem(label: 'Best margin', isAction: true),
                  ]),
                ],
              ),
              dataPane: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.rule, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} products',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.5,
                            color: c.muted,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: c.bg2,
                      border: Border(bottom: BorderSide(color: c.rule, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          flex: 3,
                          child: _ColHeader('PRODUCT', c),
                        ),
                        SizedBox(width: 100, child: _ColHeader('PRICE', c, right: true)),
                        SizedBox(width: 140, child: _ColHeader('STOCK', c)),
                        SizedBox(width: 80, child: _ColHeader('MARGIN', c, right: true)),
                        SizedBox(width: 100, child: _ColHeader('STATUS', c)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No products match this filter.',
                                style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) =>
                                _ProductRow(product: filtered[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  final BLColors c;
  final bool right;

  const _ColHeader(this.label, this.c, {this.right = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  BLStatusKind _statusKind(Product p) {
    if (p.isCriticalStock || p.isOutOfStock) return BLStatusKind.berry;
    if (p.isLowStock) return BLStatusKind.low;
    return BLStatusKind.healthy;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final p = product;

    return BLTableRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.bg3,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.rule),
              ),
              child: Center(
                child: Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                  style: GoogleFonts.newsreader(fontSize: 16, color: c.muted, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: GoogleFonts.interTight(
                          fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500, letterSpacing: -0.07)),
                  Text(p.productCode,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: c.muted, letterSpacing: 0.5)),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                'NRS ${p.currentSellingPrice.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.newsreader(
                    fontSize: 14, fontWeight: FontWeight.w500, color: c.ink, letterSpacing: -0.3),
              ),
            ),
            SizedBox(
              width: 140,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: BLStockBar(available: p.availableStock, total: p.totalStock),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                '${p.profitMargin.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: GoogleFonts.interTight(
                    fontSize: 13, color: p.profitMargin > 30 ? c.moss : c.ink2, letterSpacing: -0.07),
              ),
            ),
            SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: BLStatusPill(label: p.stockStatus, kind: _statusKind(p)),
              ),
            ),
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, size: 16, color: c.faint),
                color: c.bg2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), side: BorderSide(color: c.rule)),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: GoogleFonts.interTight(fontSize: 13, color: c.berry)),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'delete') {
                    BLConfirmDialog.show(
                      context,
                      title: 'Delete product?',
                      body: 'This will permanently delete "${p.name}" from inventory.',
                      onConfirm: () => context.read<DatabaseService>().deleteProduct(p.id),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
