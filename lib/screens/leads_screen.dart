import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/lead.dart';
import '../widgets/bl_components.dart';
import '../widgets/lead_details_sheet.dart';
import '../widgets/lead_form_dialog.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _stageFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    List<Lead> filtered;
    if (_stageFilter == 'All') {
      filtered = List.of(db.leads);
    } else {
      filtered = db.leads.where((l) => l.status.label == _stageFilter).toList();
    }
    // Sort by inquire date — most recent first
    filtered.sort((a, b) {
      final ad = a.inquireDate ?? a.createdAt;
      final bd = b.inquireDate ?? b.createdAt;
      return bd.compareTo(ad);
    });

    final open = db.leads.where((l) =>
        l.status != LeadStatus.converted && l.status != LeadStatus.lost).length;
    final awaitingReply = db.leads.where((l) => l.status == LeadStatus.replied).length;
    final quoted = db.leads.where((l) => l.status == LeadStatus.negotiating).length;
    final pipelineValue = db.leads
        .where((l) => l.finalSellingAmount != null)
        .fold(0.0, (s, l) => s + l.finalSellingAmount!);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Leads',
            title: 'Leads',
            actions: BLButton(
              label: 'Add Lead',
              kind: BLButtonKind.primary,
              leading: Icon(Icons.add, size: 14, color: c.ink),
              onPressed: () => context.go('/leads/new'),
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
                  _StatCell('OPEN', open.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('AWAITING REPLY', awaitingReply.toString(), c, isCoral: awaitingReply > 0),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('QUOTED', quoted.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('PIPELINE', 'NRS ${pipelineValue.toStringAsFixed(0)}', c),
                ],
              ),
            ),
          ),
          Divider(color: c.rule, height: 1),
          Expanded(
            child: BLWorkspace(
              filterRail: BLFilterRail(
                selectedItem: _stageFilter,
                onSelect: (group, item) => setState(() => _stageFilter = item),
                groups: const [
                  BLFilterGroup(label: 'Stage', items: [
                    BLFilterItem(label: 'All'),
                    BLFilterItem(label: 'Negotiating'),
                    BLFilterItem(label: 'Converted'),
                    BLFilterItem(label: 'Lost'),
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
                        SizedBox(width: 100, child: _ColH('DATE', c)),
                        Expanded(flex: 3, child: _ColH('NAME / PRODUCT', c)),
                        Expanded(flex: 2, child: _ColH('CONTACT', c)),
                        SizedBox(width: 110, child: _ColH('SOURCE', c)),
                        SizedBox(width: 80, child: _ColH('BUDGET', c)),
                        SizedBox(width: 160, child: _ColH('STAGE', c)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('No leads match this filter.',
                                style: GoogleFonts.interTight(fontSize: 13.5, color: c.muted)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _LeadRow(lead: filtered[i]),
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
  final bool isCoral;

  const _StatCell(this.label, this.value, this.c, {this.isCoral = false});

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
            Text(value,
                style: GoogleFonts.newsreader(
                    fontSize: 22, fontWeight: FontWeight.w500,
                    color: isCoral ? c.coral : c.ink, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }
}

class _ColH extends StatelessWidget {
  final String label;
  final BLColors c;

  const _ColH(this.label, this.c);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5));
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
    case LeadStatus.newLead:
      return BLStatusKind.neutral;
    default:
      return BLStatusKind.neutral;
  }
}

class _LeadRow extends StatelessWidget {
  final Lead lead;
  const _LeadRow({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final db = context.read<DatabaseService>();
    final productName = lead.interestedProductIds.isNotEmpty
        ? db.getProductById(lead.interestedProductIds.first)?.name
        : null;
    final isLost = lead.status == LeadStatus.lost;

    return BLTableRow(
      onTap: () => showLeadDetailsSheet(context, lead),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Date
            SizedBox(
              width: 100,
              child: Text(
                DateFormat('MMM d, yyyy').format(lead.inquireDate ?? lead.createdAt),
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5, color: c.muted, letterSpacing: 0.5),
              ),
            ),
            // Name + product
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lead.name,
                      style: GoogleFonts.interTight(
                          fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500,
                          letterSpacing: -0.07),
                      overflow: TextOverflow.ellipsis),
                  if (productName != null)
                    Text(productName,
                        style: GoogleFonts.interTight(
                            fontSize: 11, color: c.muted, letterSpacing: -0.05),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Contact
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lead.instaId != null)
                    Text(
                      '@${extractInstaUsername(lead.instaId)}',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5, color: c.coral, letterSpacing: 0.2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (lead.contactNumber != null)
                    Text(
                      lead.contactNumber!,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5, color: c.muted, letterSpacing: 0.3),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Source
            SizedBox(
              width: 110,
              child: lead.source != null
                  ? Text(
                      lead.source!.label,
                      style: GoogleFonts.interTight(
                          fontSize: 11.5,
                          color: lead.source == LeadSource.instagramAd ? c.coral : c.muted,
                          fontWeight: lead.source == LeadSource.instagramAd
                              ? FontWeight.w600
                              : FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(),
            ),
            // Budget
            SizedBox(
              width: 80,
              child: lead.budgetRange != null
                  ? Text(
                      'NRS ${lead.budgetRange}',
                      style: GoogleFonts.interTight(
                          fontSize: 11.5, color: c.muted),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(),
            ),
            // Stage
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BLStatusPill(label: lead.status.label, kind: _leadStatusKind(lead.status)),
                  if (isLost && lead.lostReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lead.lostReason!.label,
                      style: GoogleFonts.interTight(
                          fontSize: 10.5, color: c.berry, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
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
                    value: 'edit',
                    child: Text('Edit',
                        style: GoogleFonts.interTight(fontSize: 13, color: c.ink)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: GoogleFonts.interTight(fontSize: 13, color: c.berry)),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'edit') {
                    showLeadDialog(context, lead);
                  } else if (v == 'delete') {
                    BLConfirmDialog.show(
                      context,
                      title: 'Delete lead?',
                      body: 'Delete lead "${lead.name}"?',
                      onConfirm: () =>
                          context.read<DatabaseService>().deleteLead(lead.id),
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
