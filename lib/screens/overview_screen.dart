import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/lead.dart';
import '../services/database_service.dart';
import '../widgets/bl_components.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlySales = db.sales.where((s) => s.saleDate.isAfter(monthStart)).toList();
    final monthlyRevenue = monthlySales.fold(0.0, (sum, s) => sum + s.price);
    final monthlyProfit = monthlySales.fold(0.0, (sum, s) {
      final product = db.getProductById(s.productId);
      return sum + (product != null ? s.price - product.costPrice.totalCost : 0);
    });
    final monthlyExpenses = db.expenses
        .where((e) => e.date.isAfter(monthStart))
        .fold(0.0, (sum, e) => sum + e.amount);

    final lowStockCount = db.products.where((p) => p.isLowStock || p.isCriticalStock).length;
    final criticalProducts = db.products.where((p) => p.isLowStock || p.isCriticalStock).take(6).toList();
    final recentSales = db.sales.take(5).toList();
    final recentLeads = db.leads.take(3).toList();

    return Scaffold(
      backgroundColor: c.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            BLPageHeader(
              breadcrumb: 'Workspace — Overview',
              title: 'This month, at a glance.',
              subtitle: 'Your workshop at a glance.',
              actions: Row(
                children: [
                  BLButton(
                    label: 'Export',
                    kind: BLButtonKind.ghost,
                    leading: Icon(Icons.download_outlined, size: 14, color: c.ink2),
                  ),
                  const SizedBox(width: 8),
                  BLButton(
                    label: 'Record Sale',
                    kind: BLButtonKind.primary,
                    leading: Icon(Icons.add, size: 14, color: c.ink),
                    onPressed: () => context.go('/sales/new'),
                  ),
                ],
              ),
            ),
            Divider(color: c.rule, height: 1),
            // Stat strip
            _StatStrip(
              stats: [
                _Stat(label: 'PRODUCTS', value: db.totalProductCount.toString()),
                _Stat(label: 'STOCK', value: db.products.fold<int>(0, (s, p) => s + p.availableStock).toString()),
                _Stat(label: 'REVENUE', value: 'NRS ${monthlyRevenue.toStringAsFixed(0)}', isRevenue: true),
                _Stat(label: 'PROFIT', value: 'NRS ${monthlyProfit.toStringAsFixed(0)}', isProfit: true),
                _Stat(label: 'LOW STOCK', value: lowStockCount.toString(), isWarn: lowStockCount > 0),
                _Stat(label: 'EXPENSES', value: 'NRS ${monthlyExpenses.toStringAsFixed(0)}', isBerry: true),
              ],
            ),
            Divider(color: c.rule, height: 1),
            const SizedBox(height: 28),
            // Overview grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Critical stock
                  Expanded(
                    flex: 5,
                    child: BLSectionCard(
                      title: 'Critical stock',
                      padding: EdgeInsets.zero,
                      child: criticalProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('All products are well-stocked.',
                                  style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)),
                            )
                          : Column(
                              children: [
                                _CriticalStockHeader(c: c),
                                ...criticalProducts.map(
                                  (p) => BLTableRow(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(p.name,
                                                style: GoogleFonts.interTight(
                                                    fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500)),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: BLStockBar(
                                                available: p.availableStock, total: p.totalStock),
                                          ),
                                          const SizedBox(width: 16),
                                          BLStatusPill(
                                            label: p.stockStatus,
                                            kind: p.isCriticalStock
                                                ? BLStatusKind.berry
                                                : BLStatusKind.low,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Recent activity
                  Expanded(
                    flex: 3,
                    child: BLSectionCard(
                      title: 'Recent activity',
                      padding: EdgeInsets.zero,
                      child: recentSales.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('No sales yet.',
                                  style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)),
                            )
                          : Column(
                              children: recentSales.map((s) {
                                final product = db.getProductById(s.productId);
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: c.rule, width: 1)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat('MMM d').format(s.saleDate),
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10.5,
                                          color: c.muted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product?.name ?? 'Unknown',
                                              style: GoogleFonts.interTight(
                                                fontSize: 13,
                                                color: c.ink,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              s.customer.name,
                                              style: GoogleFonts.interTight(
                                                fontSize: 11.5,
                                                color: c.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: c.moss.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: c.moss.withOpacity(0.25)),
                                        ),
                                        child: Text(
                                          'NRS ${s.price.toStringAsFixed(0)}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: c.moss,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pipeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: BLSectionCard(
                title: 'Pipeline',
                padding: EdgeInsets.zero,
                child: recentLeads.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('No leads yet.',
                            style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)),
                      )
                    : Column(
                        children: recentLeads.map((lead) {
                          final isOverdue = lead.isOverdueFollowUp;
                          return BLTableRow(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(lead.name,
                                        style: GoogleFonts.interTight(
                                            fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500)),
                                  ),
                                  BLStatusPill(
                                    label: lead.status.label,
                                    kind: _leadStatusKind(lead.status),
                                  ),
                                  const SizedBox(width: 16),
                                  if (lead.followUpDate != null)
                                    Text(
                                      'Follow up: ${DateFormat('MMM d').format(lead.followUpDate!)}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10.5,
                                        color: isOverdue ? c.coral : c.muted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

BLStatusKind _leadStatusKind(LeadStatus status) {
  switch (status) {
    case LeadStatus.converted:
      return BLStatusKind.healthy;
    case LeadStatus.lost:
      return BLStatusKind.berry;
    case LeadStatus.negotiating:
    case LeadStatus.interested:
      return BLStatusKind.warn;
    default:
      return BLStatusKind.neutral;
  }
}

class _CriticalStockHeader extends StatelessWidget {
  final BLColors c;
  const _CriticalStockHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.rule))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text('PRODUCT',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          ),
          SizedBox(
            width: 120,
            child: Text('STOCK',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text('STATUS',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final bool isProfit;
  final bool isRevenue;
  final bool isWarn;
  final bool isBerry;

  const _Stat({
    required this.label,
    required this.value,
    this.isProfit = false,
    this.isRevenue = false,
    this.isWarn = false,
    this.isBerry = false,
  });
}

class _StatStrip extends StatelessWidget {
  final List<_Stat> stats;

  const _StatStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return IntrinsicHeight(
      child: Row(
        children: List.generate(stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return VerticalDivider(width: 1, color: c.rule);
          }
          final stat = stats[i ~/ 2];
          return Expanded(child: _StatTile(stat: stat));
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _Stat stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    Color valueColor = c.ink;
    if (stat.isProfit) valueColor = c.coral;
    if (stat.isWarn) valueColor = c.coral;
    if (stat.isBerry) valueColor = c.berry;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9.5,
              color: c.muted,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: GoogleFonts.newsreader(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              
              color: valueColor,
              letterSpacing: -0.65,
            ),
          ),
        ],
      ),
    );
  }
}
