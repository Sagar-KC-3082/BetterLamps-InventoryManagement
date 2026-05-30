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

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _q = _searchCtrl.text.toLowerCase().trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db  = context.watch<DatabaseService>();
    final c   = context.blColors;
    final all = db.leads;

    // counts
    final nAll         = all.length;
    final nNegotiating = all.where((l) => l.status == LeadStatus.negotiating).length;
    final nConverted   = all.where((l) => l.status == LeadStatus.converted).length;
    final nLost        = all.where((l) => l.status == LeadStatus.lost).length;
    final nOpen        = all.where((l) =>
        l.status != LeadStatus.converted && l.status != LeadStatus.lost).length;
    final rate         = nAll > 0 ? nConverted / nAll * 100 : 0.0;

    // filter
    List<Lead> list = _filter == 'All'
        ? List.of(all)
        : all.where((l) => l.status.label == _filter).toList();

    // search
    if (_q.isNotEmpty) {
      list = list.where((l) {
        final prod = l.interestedProductIds.isNotEmpty
            ? (db.getProductById(l.interestedProductIds.first)?.name ?? '')
            : '';
        return l.name.toLowerCase().contains(_q) ||
            prod.toLowerCase().contains(_q) ||
            (l.contactNumber?.contains(_q) ?? false) ||
            (l.instaId?.toLowerCase().contains(_q) ?? false);
      }).toList();
    }

    // sort newest inquire first
    list.sort((a, b) {
      final ad = a.inquireDate ?? a.createdAt;
      final bd = b.inquireDate ?? b.createdAt;
      return bd.compareTo(ad);
    });

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────────────────
          _TopBar(c: c, total: nAll),

          // ── Stats ribbon ─────────────────────────────────────────────────
          _StatsRibbon(
            c: c,
            open: nOpen,
            negotiating: nNegotiating,
            converted: nConverted,
            lost: nLost,
            rate: rate,
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left sidebar
                _Sidebar(
                  c: c,
                  selected: _filter,
                  counts: {
                    'All': nAll,
                    'Negotiating': nNegotiating,
                    'Converted': nConverted,
                    'Lost': nLost,
                  },
                  onSelect: (v) => setState(() => _filter = v),
                ),
                VerticalDivider(width: 1, color: c.rule),

                // main pane
                Expanded(
                  child: Column(
                    children: [
                      _SearchBar(c: c, ctrl: _searchCtrl, count: list.length),
                      Divider(height: 1, color: c.rule),
                      Expanded(
                        child: list.isEmpty
                            ? _Empty(c: c, searching: _q.isNotEmpty)
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: list.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: c.rule),
                                itemBuilder: (ctx, i) =>
                                    _LeadCard(lead: list[i]),
                              ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final BLColors c;
  final int total;
  const _TopBar({required this.c, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(bottom: BorderSide(color: c.rule)),
      ),
      child: Row(
        children: [
          Text(
            'Leads',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w500,
                color: c.ink, letterSpacing: -0.5),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: c.bg3,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.rule),
            ),
            child: Text(
              '$total',
              style: GoogleFonts.inter(
                  fontSize: 10.5, color: c.muted, letterSpacing: 0.5),
            ),
          ),
          const Spacer(),
          // breadcrumb
          Text(
            'Workspace  ·  Leads',
            style: GoogleFonts.inter(
                fontSize: 9.5, color: c.faint, letterSpacing: 0.8),
          ),
          const SizedBox(width: 20),
          BLButton(
            label: 'Add Lead',
            kind: BLButtonKind.primary,
            leading: Icon(Icons.add, size: 13, color: c.bg),
            onPressed: () => context.go('/leads/new'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats ribbon
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRibbon extends StatelessWidget {
  final BLColors c;
  final int open, negotiating, converted, lost;
  final double rate;
  const _StatsRibbon({
    required this.c,
    required this.open,
    required this.negotiating,
    required this.converted,
    required this.lost,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.bg2,
        border: Border(bottom: BorderSide(color: c.rule)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Cell(label: 'OPEN', value: '$open', color: open > 0 ? c.coral : c.ink, c: c),
            VerticalDivider(width: 1, color: c.rule),
            _Cell(label: 'NEGOTIATING', value: '$negotiating', color: negotiating > 0 ? c.gold : c.ink, c: c),
            VerticalDivider(width: 1, color: c.rule),
            _Cell(label: 'CONVERTED', value: '$converted', color: converted > 0 ? c.moss : c.ink, c: c),
            VerticalDivider(width: 1, color: c.rule),
            _Cell(label: 'LOST', value: '$lost', color: lost > 0 ? c.berry : c.ink, c: c),
            VerticalDivider(width: 1, color: c.rule),
            _Cell(
              label: 'CONV. RATE',
              value: '${rate.toStringAsFixed(1)}%',
              color: rate > 20 ? c.moss : rate > 0 ? c.gold : c.muted,
              c: c,
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label, value;
  final Color color;
  final BLColors c;
  const _Cell({required this.label, required this.value, required this.color, required this.c});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 8.5, color: c.muted,
                    fontWeight: FontWeight.w600, letterSpacing: 1.6)),
            const SizedBox(height: 5),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w500,
                    color: color, letterSpacing: -0.6)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final BLColors c;
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;
  const _Sidebar({
    required this.c,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      color: c.bg2,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text('STAGE',
                style: GoogleFonts.inter(
                    fontSize: 8.5, color: c.faint,
                    fontWeight: FontWeight.w600, letterSpacing: 1.8)),
          ),
          for (final entry in counts.entries)
            _SideItem(
              label: entry.key,
              count: entry.value,
              selected: selected == entry.key,
              c: c,
              onTap: () => onSelect(entry.key),
            ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final BLColors c;
  final VoidCallback onTap;
  const _SideItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  Color _accentFor(String l) {
    switch (l) {
      case 'Converted':  return c.moss;
      case 'Lost':       return c.berry;
      case 'Negotiating':return c.gold;
      default:           return c.coral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.25) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // color dot
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: selected ? accent : c.faint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? accent : c.ink2,
                  letterSpacing: -0.05,
                ),
              ),
            ),
            // count badge
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? accent.withValues(alpha: 0.18) : c.bg3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? accent : c.muted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final BLColors c;
  final TextEditingController ctrl;
  final int count;
  const _SearchBar({required this.c, required this.ctrl, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: c.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: c.faint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: GoogleFonts.inter(fontSize: 13, color: c.ink),
              decoration: InputDecoration(
                hintText: 'Search by name, product, handle…',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: c.faint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          Text(
            '$count result${count == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
                fontSize: 9.5, color: c.faint, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lead card
// ─────────────────────────────────────────────────────────────────────────────

class _LeadCard extends StatefulWidget {
  final Lead lead;
  const _LeadCard({required this.lead});

  @override
  State<_LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<_LeadCard> {
  bool _hovered = false;

  Color _statusColor(BLColors c) {
    switch (widget.lead.status) {
      case LeadStatus.converted:  return c.moss;
      case LeadStatus.lost:       return c.berry;
      case LeadStatus.negotiating:return c.gold;
      case LeadStatus.interested: return c.gold;
      default:                    return c.faint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c     = context.blColors;
    final db    = context.read<DatabaseService>();
    final lead  = widget.lead;
    final prod  = lead.interestedProductIds.isNotEmpty
        ? db.getProductById(lead.interestedProductIds.first)
        : null;
    final accent = _statusColor(c);
    final isLost = lead.status == LeadStatus.lost;
    final isConverted = lead.status == LeadStatus.converted;
    final date = lead.inquireDate ?? lead.createdAt;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showLeadDetailsSheet(context, lead),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: _hovered
                ? c.bgHover
                : isLost
                    ? c.berry.withValues(alpha: 0.05)
                    : isConverted
                        ? c.moss.withValues(alpha: 0.04)
                        : c.bg,
            border: Border(left: BorderSide(color: accent, width: 3)),
          ),
          child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        _Avatar(name: lead.name, accent: accent, c: c),
                        const SizedBox(width: 14),

                        // Identity + details
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name
                              Text(
                                lead.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: c.ink,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              // Sub-line: product · handle/phone
                              _SubLine(lead: lead, prod: prod?.name, c: c),
                              // Lost reason
                              if (isLost && lead.lostReason != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sentiment_dissatisfied_outlined,
                                        size: 11, color: c.berry),
                                    const SizedBox(width: 4),
                                    Text(
                                      lead.lostReason!.label,
                                      style: GoogleFonts.inter(
                                          fontSize: 11, color: c.berry,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── Right side metadata ───────────────────────────
                        // Source
                        SizedBox(
                          width: 130,
                          child: lead.source != null
                              ? _SourceBadge(source: lead.source!, c: c)
                              : const SizedBox(),
                        ),

                        // Budget
                        SizedBox(
                          width: 90,
                          child: lead.budgetRange != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'NRS ${lead.budgetRange}',
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: c.ink,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.2),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text('budget',
                                        style: GoogleFonts.inter(
                                            fontSize: 9.5, color: c.faint)),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(width: 12),

                        // Date
                        SizedBox(
                          width: 76,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMM d').format(date),
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: c.ink2,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat('yyyy').format(date),
                                style: GoogleFonts.inter(
                                    fontSize: 9.5, color: c.faint,
                                    letterSpacing: 0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Status pill
                        SizedBox(
                          width: 100,
                          child: BLStatusPill(
                            label: lead.status.label,
                            kind: _statusKind(lead.status),
                          ),
                        ),

                        // More menu
                        SizedBox(
                          width: 32,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_horiz, size: 15,
                                color: _hovered ? c.muted : c.faint),
                            color: c.bg2,
                            splashRadius: 14,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: c.rule),
                            ),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 14, color: c.muted),
                                  const SizedBox(width: 8),
                                  Text('Edit',
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: c.ink)),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline, size: 14, color: c.berry),
                                  const SizedBox(width: 8),
                                  Text('Delete',
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: c.berry)),
                                ]),
                              ),
                            ],
                            onSelected: (v) {
                              if (v == 'edit') {
                                showLeadDialog(context, lead);
                              } else if (v == 'delete') {
                                BLConfirmDialog.show(
                                  context,
                                  title: 'Delete lead?',
                                  body: 'Delete "${lead.name}"? This cannot be undone.',
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
          ),
        ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final Color accent;
  final BLColors c;
  const _Avatar({required this.name, required this.accent, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, color: accent),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-line (product · handle / phone)
// ─────────────────────────────────────────────────────────────────────────────

class _SubLine extends StatelessWidget {
  final Lead lead;
  final String? prod;
  final BLColors c;
  const _SubLine({required this.lead, required this.prod, required this.c});

  @override
  Widget build(BuildContext context) {
    final parts = <InlineSpan>[];

    if (prod != null) {
      parts.add(TextSpan(
        text: prod,
        style: GoogleFonts.inter(
            fontSize: 11.5, color: c.muted, letterSpacing: -0.05),
      ));
    }

    final handle = lead.instaId != null
        ? '@${extractInstaUsername(lead.instaId)}'
        : null;

    if (handle != null) {
      if (parts.isNotEmpty) {
        parts.add(TextSpan(
          text: '  ·  ',
          style: GoogleFonts.inter(fontSize: 11.5, color: c.faint),
        ));
      }
      parts.add(TextSpan(
        text: handle,
        style: GoogleFonts.inter(
            fontSize: 10.5, color: c.coral, letterSpacing: 0.2),
      ));
    } else if (lead.contactNumber != null) {
      if (parts.isNotEmpty) {
        parts.add(TextSpan(
          text: '  ·  ',
          style: GoogleFonts.inter(fontSize: 11.5, color: c.faint),
        ));
      }
      parts.add(TextSpan(
        text: lead.contactNumber!,
        style: GoogleFonts.inter(
            fontSize: 10.5, color: c.muted, letterSpacing: 0.3),
      ));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: parts),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Source badge
// ─────────────────────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final LeadSource source;
  final BLColors c;
  const _SourceBadge({required this.source, required this.c});

  @override
  Widget build(BuildContext context) {
    final isIG = source == LeadSource.instagramAd;
    final color = isIG ? c.coral : c.muted;
    final bg    = isIG ? c.coral.withValues(alpha: 0.10) : c.bg3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withValues(alpha: isIG ? 0.25 : 0.0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIG ? Icons.auto_awesome : Icons.campaign_outlined,
                size: 10, color: color,
              ),
              const SizedBox(width: 4),
              Text(
                source.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isIG ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                  letterSpacing: -0.04,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final BLColors c;
  final bool searching;
  const _Empty({required this.c, required this.searching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: c.bg3,
              shape: BoxShape.circle,
              border: Border.all(color: c.rule),
            ),
            child: Icon(
              searching ? Icons.search_off : Icons.person_outline,
              size: 22, color: c.faint,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            searching ? 'No leads match that search.' : 'No leads here yet.',
            style: GoogleFonts.inter(
                fontSize: 16, color: c.muted, letterSpacing: -0.2),
          ),
          if (!searching) ...[
            const SizedBox(height: 6),
            Text(
              'Add your first lead to get started.',
              style: GoogleFonts.inter(fontSize: 12.5, color: c.faint),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

BLStatusKind _statusKind(LeadStatus s) {
  switch (s) {
    case LeadStatus.converted:   return BLStatusKind.healthy;
    case LeadStatus.lost:        return BLStatusKind.berry;
    case LeadStatus.negotiating:
    case LeadStatus.interested:  return BLStatusKind.warn;
    default:                     return BLStatusKind.neutral;
  }
}
