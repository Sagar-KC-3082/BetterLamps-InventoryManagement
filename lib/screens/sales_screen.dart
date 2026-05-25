import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/sale.dart';
import '../widgets/bl_components.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _periodFilter = 'This month';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = monthStart;

    List<Sale> filtered;
    switch (_periodFilter) {
      case 'Last month':
        filtered = db.sales
            .where((s) => s.saleDate.isAfter(lastMonthStart) && s.saleDate.isBefore(lastMonthEnd))
            .toList();
        break;
      case 'All time':
        filtered = db.sales;
        break;
      default:
        filtered = db.sales.where((s) => s.saleDate.isAfter(monthStart)).toList();
    }

    final revenue = filtered.fold(0.0, (s, sale) => s + sale.price);
    final profit = filtered.fold(0.0, (sum, sale) {
      final p = db.getProductById(sale.productId);
      return sum + (p != null ? sale.price - p.costPrice.totalCost : 0);
    });
    final avgTicket = filtered.isEmpty ? 0.0 : revenue / filtered.length;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Sales',
            title: 'Sales',
            actions: BLButton(
              label: 'Record Sale',
              kind: BLButtonKind.primary,
              leading: Icon(Icons.add, size: 14, color: c.ink),
              onPressed: () => context.go('/sales/new'),
            ),
          ),
          // Stats strip
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: c.rule, width: 1),
                bottom: BorderSide(color: c.rule, width: 1),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell('SALES', filtered.length.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('REVENUE', 'NRS ${revenue.toStringAsFixed(0)}', c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('PROFIT', 'NRS ${profit.toStringAsFixed(0)}', c, isProfit: true),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('AVG TICKET', 'NRS ${avgTicket.toStringAsFixed(0)}', c),
                ],
              ),
            ),
          ),
          Divider(color: c.rule, height: 1),
          Expanded(
            child: BLWorkspace(
              filterRail: BLFilterRail(
                selectedItem: _periodFilter,
                onSelect: (group, item) => setState(() => _periodFilter = item),
                groups: const [
                  BLFilterGroup(label: 'Period', items: [
                    BLFilterItem(label: 'This month'),
                    BLFilterItem(label: 'Last month'),
                    BLFilterItem(label: 'All time'),
                  ]),
                ],
              ),
              dataPane: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: c.bg2,
                      border: Border(bottom: BorderSide(color: c.rule, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: _ColH('DATE', c)),
                        Expanded(flex: 2, child: _ColH('PRODUCT', c)),
                        Expanded(flex: 2, child: _ColH('CUSTOMER', c)),
                        SizedBox(width: 100, child: _ColH('SOURCE', c)),
                        SizedBox(width: 100, child: _ColH('AMOUNT', c, right: true)),
                        SizedBox(width: 80, child: _ColH('PROFIT', c, right: true)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No sales for this period.',
                                style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) =>
                                _SaleRow(sale: filtered[i]),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final BLColors c;
  final bool isProfit;

  const _StatCell(this.label, this.value, this.c, {this.isProfit = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                
                color: isProfit ? c.coral : c.ink,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColH extends StatelessWidget {
  final String label;
  final BLColors c;
  final bool right;

  const _ColH(this.label, this.c, {this.right = false});

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

class _SaleRow extends StatelessWidget {
  final Sale sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final db = context.read<DatabaseService>();
    final product = db.getProductById(sale.productId);
    final profit = product != null ? sale.price - product.costPrice.totalCost : 0.0;

    return BLTableRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                DateFormat('MMM d').format(sale.saleDate),
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5, color: c.muted, letterSpacing: 0.5),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                        color: c.bg3, borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: c.rule)),
                    child: Center(
                      child: Text(
                        product?.name.isNotEmpty == true ? product!.name[0] : '?',
                        style: GoogleFonts.newsreader(fontSize: 13, color: c.muted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product?.name ?? 'Unknown product',
                      style: GoogleFonts.interTight(
                          fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500,
                          letterSpacing: -0.07),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.customer.name,
                      style: GoogleFonts.interTight(
                          fontSize: 13, color: c.ink, letterSpacing: -0.07)),
                  Text(sale.customer.phone,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, color: c.muted, letterSpacing: 0.3)),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: sale.source != null
                  ? BLStatusPill(label: sale.source!, kind: BLStatusKind.neutral)
                  : const SizedBox(),
            ),
            SizedBox(
              width: 100,
              child: Text(
                'NRS ${sale.price.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.newsreader(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: c.ink, letterSpacing: -0.3),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                '+${profit.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.newsreader(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: c.moss, letterSpacing: -0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
