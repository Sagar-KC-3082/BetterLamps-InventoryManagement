import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/expense.dart';
import '../widgets/bl_components.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    List<Expense> filtered = db.expenses;
    if (_filter != 'All') {
      filtered = db.expenses.where((e) => e.person == _filter).toList();
    }

    final total = filtered.fold(0.0, (s, e) => s + e.amount);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthly = db.expenses
        .where((e) => e.date.isAfter(monthStart))
        .fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Expenses',
            title: 'Expenses',
            actions: BLButton(
              label: 'Add Expense',
              kind: BLButtonKind.primary,
              leading: Icon(Icons.add, size: 14, color: c.ink),
              onPressed: () => context.go('/expenses/new'),
            ),
          ),
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
                  _StatCell('TOTAL', 'NRS ${total.toStringAsFixed(0)}', c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('THIS MONTH', 'NRS ${monthly.toStringAsFixed(0)}', c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('ENTRIES', filtered.length.toString(), c),
                ],
              ),
            ),
          ),
          Divider(color: c.rule, height: 1),
          Expanded(
            child: BLWorkspace(
              filterRail: BLFilterRail(
                selectedItem: _filter,
                onSelect: (group, item) => setState(() => _filter = item),
                groups: [
                  BLFilterGroup(
                    label: 'Person',
                    items: [
                      const BLFilterItem(label: 'All'),
                      ...db.expenses
                          .map((e) => e.person)
                          .toSet()
                          .map((p) => BLFilterItem(label: p)),
                    ],
                  ),
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
                        SizedBox(width: 100, child: _ColH('PERSON', c)),
                        Expanded(child: _ColH('DESCRIPTION', c)),
                        SizedBox(width: 120, child: _ColH('AMOUNT', c, right: true)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No expenses yet.',
                                style: GoogleFonts.inter(fontSize: 13.5, color: c.muted)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _ExpenseRow(expense: filtered[i]),
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

  const _StatCell(this.label, this.value, this.c);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w500, color: c.ink, letterSpacing: -0.5)),
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
      style: GoogleFonts.inter(
          fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return BLTableRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                DateFormat('MMM d').format(expense.date),
                style: GoogleFonts.inter(
                    fontSize: 10.5, color: c.muted, letterSpacing: 0.5),
              ),
            ),
            SizedBox(
              width: 100,
              child: BLStatusPill(label: expense.person, kind: BLStatusKind.neutral),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.name,
                      style: GoogleFonts.inter(
                          fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500,
                          letterSpacing: -0.07)),
                  if (expense.notes != null)
                    Text(expense.notes!,
                        style: GoogleFonts.inter(
                            fontSize: 11.5, color: c.muted, letterSpacing: -0.06)),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                '− NRS ${expense.amount.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: c.berry, letterSpacing: -0.3),
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
                        style: GoogleFonts.inter(fontSize: 13, color: c.berry)),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'delete') {
                    BLConfirmDialog.show(
                      context,
                      title: 'Delete expense?',
                      body: 'Delete "${expense.name}" (NRS ${expense.amount.toStringAsFixed(0)})?',
                      onConfirm: () =>
                          context.read<DatabaseService>().deleteExpense(expense.id),
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
