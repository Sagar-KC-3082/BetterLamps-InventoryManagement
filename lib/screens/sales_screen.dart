import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/sale.dart';
import '../widgets/bl_components.dart';
import '../widgets/sale_details_sheet.dart';

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
            .where((s) =>
                s.saleDate.isAfter(lastMonthStart) &&
                s.saleDate.isBefore(lastMonthEnd))
            .toList();
        break;
      case 'All time':
        filtered = db.sales;
        break;
      default:
        filtered =
            db.sales.where((s) => s.saleDate.isAfter(monthStart)).toList();
    }

    final revenue = filtered.fold(0.0, (s, sale) => s + sale.totalAmount);
    final profit = filtered.fold(0.0, (sum, sale) {
      final p = db.getProductById(sale.productId);
      return sum +
          (p != null
              ? sale.totalAmount - p.costPrice.totalCost * sale.quantity
              : 0);
    });
    final avgTicket = filtered.isEmpty ? 0.0 : revenue / filtered.length;
    final unitsSold = filtered.fold(0, (s, sale) => s + sale.quantity);

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
                  _StatCell('ORDERS', filtered.length.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('UNITS SOLD', unitsSold.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('REVENUE', 'NRS ${_fmt(revenue)}', c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('PROFIT', 'NRS ${_fmt(profit)}', c, highlight: profit > 0 ? c.moss : c.berry),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('AVG ORDER', 'NRS ${_fmt(avgTicket)}', c),
                ],
              ),
            ),
          ),
          Expanded(
            child: BLWorkspace(
              filterRail: BLFilterRail(
                selectedItem: _periodFilter,
                onSelect: (group, item) =>
                    setState(() => _periodFilter = item),
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
                  // Table header
                  Container(
                    decoration: BoxDecoration(
                      color: c.bg2,
                      border: Border(
                          bottom: BorderSide(color: c.rule, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 68, child: _ColH('DATE', c)),
                        Expanded(flex: 5, child: _ColH('PRODUCT', c)),
                        Expanded(flex: 5, child: _ColH('CUSTOMER', c)),
                        Expanded(flex: 3, child: _ColH('SOURCE', c)),
                        Expanded(flex: 3, child: _ColH('PAYMENT', c)),
                        SizedBox(
                            width: 90,
                            child: _ColH('AMOUNT', c, right: true)),
                        SizedBox(
                            width: 86,
                            child: _ColH('PROFIT', c, right: true)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No sales for this period.',
                                style: GoogleFonts.inter(
                                    fontSize: 13.5, color: c.muted)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _SaleRow(
                              sale: filtered[i],
                              onTap: () {
                                final db = ctx.read<DatabaseService>();
                                final product = db.getProductById(filtered[i].productId);
                                showSaleDetailsSheet(ctx, filtered[i], product);
                              },
                            ),
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

String _fmt(double v) => v.toStringAsFixed(0);

// ─── Stat cell ────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final BLColors c;
  final Color? highlight;

  const _StatCell(this.label, this.value, this.c, {this.highlight});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9, color: c.muted,
                    fontWeight: FontWeight.w500, letterSpacing: 1.4)),
            const SizedBox(height: 5),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: highlight ?? c.ink,
                    letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Column header ────────────────────────────────────────────────────────────

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
      style: GoogleFonts.inter(
          fontSize: 9, color: c.muted,
          fontWeight: FontWeight.w500, letterSpacing: 1.4),
    );
  }
}

// ─── Payment method icon ──────────────────────────────────────────────────────

IconData _paymentIcon(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cash:
      return Icons.payments_outlined;
    case PaymentMethod.esewa:
    case PaymentMethod.fonepay:
      return Icons.phone_android_outlined;
    case PaymentMethod.bankTransfer:
      return Icons.account_balance_outlined;
  }
}

IconData _sourceIcon(SaleSource s) {
  switch (s) {
    case SaleSource.instagramDm:
    case SaleSource.instagramAd:
      return Icons.camera_alt_outlined;
    case SaleSource.referral:
      return Icons.people_outline;
    case SaleSource.walkIn:
      return Icons.store_outlined;
    case SaleSource.other:
      return Icons.more_horiz;
  }
}

// ─── Sale row ─────────────────────────────────────────────────────────────────

class _SaleRow extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onTap;

  const _SaleRow({required this.sale, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final db = context.read<DatabaseService>();
    final product = db.getProductById(sale.productId);
    final profit = product != null
        ? sale.totalAmount - product.costPrice.totalCost * sale.quantity
        : null;

    return BLTableRow(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            // DATE
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d').format(sale.saleDate),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: c.ink2, letterSpacing: 0.3),
                  ),
                  Text(
                    DateFormat('yyyy').format(sale.saleDate),
                    style: GoogleFonts.inter(
                        fontSize: 9.5, color: c.muted, letterSpacing: 0.3),
                  ),
                ],
              ),
            ),

            // PRODUCT (+ qty badge if >1)
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  ProductThumb(product: product, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? 'Unknown product',
                          style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: c.ink,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sale.quantity > 1)
                          Text(
                            '${sale.quantity} units',
                            style: GoogleFonts.inter(
                                fontSize: 9.5, color: c.coral, letterSpacing: 0.2),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CUSTOMER
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.customer.name,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: c.ink, letterSpacing: -0.07),
                      overflow: TextOverflow.ellipsis),
                  Text(sale.customer.phone,
                      style: GoogleFonts.inter(
                          fontSize: 9.5, color: c.muted, letterSpacing: 0.2)),
                ],
              ),
            ),

            // SOURCE — icon + label, no pill
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(_sourceIcon(sale.source), size: 13, color: c.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      sale.source.label,
                      style: GoogleFonts.inter(
                          fontSize: 12.5, color: c.ink2, letterSpacing: -0.07),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // PAYMENT — icon + label, no pill
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(_paymentIcon(sale.paymentMethod), size: 13, color: c.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      sale.paymentMethod.label,
                      style: GoogleFonts.inter(
                          fontSize: 12.5, color: c.ink2, letterSpacing: -0.07),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // AMOUNT
            SizedBox(
              width: 90,
              child: Text(
                'NRS ${_fmt(sale.totalAmount)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.ink,
                    letterSpacing: -0.3),
              ),
            ),

            // PROFIT
            SizedBox(
              width: 86,
              child: profit != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${profit >= 0 ? '+' : '−'} ${_fmt(profit.abs())}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: profit >= 0 ? c.moss : c.berry,
                              letterSpacing: -0.3),
                        ),
                        if (sale.totalAmount > 0)
                          Text(
                            '${(profit / sale.totalAmount * 100).toStringAsFixed(0)}% margin',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                color: c.muted,
                                letterSpacing: 0.2),
                          ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
