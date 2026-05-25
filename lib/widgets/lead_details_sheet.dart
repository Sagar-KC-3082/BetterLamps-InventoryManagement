import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/lead.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bl_components.dart';
import 'lead_form_dialog.dart';

/// Extracts @username from a raw instaId value, which may be:
///   • a full URL:  https://www.instagram.com/username/
///   • a handle:   @username  or  username
String? extractInstaUsername(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  // Try URL parse first
  final uri = Uri.tryParse(s);
  if (uri != null && uri.host.contains('instagram')) {
    final seg = uri.pathSegments.where((p) => p.isNotEmpty).firstOrNull;
    if (seg != null) return seg;
  }
  // Plain handle
  return s.startsWith('@') ? s.substring(1) : s;
}

/// Returns a clean profile URL regardless of input format.
String? instaProfileUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final username = extractInstaUsername(raw);
  if (username == null) return null;
  // If the original already looks like a URL, return it as-is (cleaned)
  final s = raw.trim();
  if (s.startsWith('http')) return s.replaceAll(RegExp(r'\/+$'), '');
  return 'https://instagram.com/$username';
}

void showLeadDetailsSheet(BuildContext context, Lead lead) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: _LeadDetailsSheet(lead: lead),
      );
    },
  );
}

// ─── Main sheet ────────────────────────────────────────────────────────────────

class _LeadDetailsSheet extends StatelessWidget {
  final Lead lead;
  const _LeadDetailsSheet({required this.lead});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;
    final w = MediaQuery.of(context).size.width * 0.44;
    final interestedProducts = lead.interestedProductIds
        .map((id) => db.getProductById(id))
        .whereType<Product>()
        .toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: c.bg,
          border: Border(left: BorderSide(color: c.rule)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _Header(lead: lead, c: c),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status + flags row ──
                    _FlagsRow(lead: lead, c: c),
                    const SizedBox(height: 20),

                    // ── Interested products (with images) ──
                    if (interestedProducts.isNotEmpty) ...[
                      _ProductsCard(products: interestedProducts, c: c),
                      const SizedBox(height: 20),
                    ],

                    // ── Contact ──
                    _Section(
                      title: 'Contact',
                      c: c,
                      rows: [
                        if (lead.instaId != null) ...[
                          _Row(
                            icon: Icons.alternate_email,
                            label: 'Username',
                            value: '@${extractInstaUsername(lead.instaId)}',
                            valueColor: c.coral,
                            c: c,
                          ),
                          _Row(
                            icon: Icons.link_outlined,
                            label: 'Profile link',
                            value: instaProfileUrl(lead.instaId) ?? lead.instaId!,
                            c: c,
                          ),
                        ],
                        if (lead.contactNumber != null)
                          _Row(icon: Icons.phone_outlined, label: 'Phone', value: lead.contactNumber!, c: c),
                        if (lead.alternateContact != null)
                          _Row(icon: Icons.contact_phone_outlined, label: 'Alternate', value: lead.alternateContact!, c: c),
                        if (lead.address != null)
                          _Row(icon: Icons.location_on_outlined, label: 'Location', value: lead.address!, c: c),
                        if (lead.gender != null)
                          _Row(icon: Icons.wc_outlined, label: 'Gender', value: lead.gender!.label, c: c),
                        if (lead.age != null)
                          _Row(icon: Icons.cake_outlined, label: 'Age', value: '${lead.age}', c: c),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Inquiry ──
                    _Section(
                      title: 'Inquiry',
                      c: c,
                      rows: [
                        if (lead.source != null)
                          _Row(icon: Icons.campaign_outlined, label: 'Source', value: lead.source!.label, c: c),
                        if (lead.inquireDate != null)
                          _Row(
                            icon: Icons.calendar_today_outlined,
                            label: 'Inquired',
                            value: DateFormat('MMM d, yyyy · h:mm a').format(lead.inquireDate!),
                            c: c,
                          ),
                        if (lead.budgetRange != null)
                          _Row(icon: Icons.payments_outlined, label: 'Budget', value: 'NRS ${lead.budgetRange}', c: c),
                        if (lead.quantityInterested != null)
                          _Row(
                            icon: Icons.production_quantity_limits_outlined,
                            label: 'Quantity',
                            value: '${lead.quantityInterested}',
                            c: c,
                          ),
                        if (lead.expectedDeliveryDate != null)
                          _Row(
                            icon: Icons.local_shipping_outlined,
                            label: 'Expected by',
                            value: DateFormat('MMM d, yyyy').format(lead.expectedDeliveryDate!),
                            c: c,
                          ),
                        if (lead.customRequirements != null)
                          _Row(
                            icon: Icons.sticky_note_2_outlined,
                            label: 'Notes',
                            value: lead.customRequirements!,
                            multiLine: true,
                            c: c,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Outcome (only if converted / lost) ──
                    if (lead.didBuy || lead.status == LeadStatus.lost) ...[
                      _Section(
                        title: 'Outcome',
                        c: c,
                        rows: [
                          _Row(
                            icon: lead.didBuy ? Icons.check_circle_outline : Icons.cancel_outlined,
                            label: 'Bought',
                            value: lead.didBuy ? 'Yes' : 'No',
                            valueColor: lead.didBuy ? c.moss : c.berry,
                            c: c,
                          ),
                          if (lead.didBuy) ...[
                            if (lead.purchasedProductIds.isNotEmpty)
                              _Row(
                                icon: Icons.shopping_bag_outlined,
                                label: 'Purchased',
                                value: lead.purchasedProductIds
                                    .map((id) => db.getProductById(id)?.name ?? id)
                                    .join(', '),
                                c: c,
                              ),
                            if (lead.finalSellingAmount != null)
                              _Row(
                                icon: Icons.payments_outlined,
                                label: 'Final amount',
                                value: 'NRS ${lead.finalSellingAmount!.toStringAsFixed(0)}',
                                valueColor: c.moss,
                                c: c,
                              ),
                          ],
                          if (!lead.didBuy) ...[
                            if (lead.lostReason != null)
                              _Row(
                                icon: Icons.sentiment_dissatisfied_outlined,
                                label: 'Lost reason',
                                value: lead.lostReason!.label,
                                valueColor: c.berry,
                                c: c,
                              ),
                            if (lead.lostReasonNote != null)
                              _Row(icon: Icons.notes_outlined, label: 'Note', value: lead.lostReasonNote!, c: c),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
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

// ─── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Lead lead;
  final BLColors c;
  const _Header({required this.lead, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
      decoration: BoxDecoration(
        color: c.bg2,
        border: Border(bottom: BorderSide(color: c.rule)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.coral.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: c.coral.withOpacity(0.25)),
            ),
            child: Center(
              child: Text(
                lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                style: GoogleFonts.newsreader(
                    fontSize: 20, fontWeight: FontWeight.w600, color: c.coral),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: GoogleFonts.newsreader(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: c.ink,
                      letterSpacing: -0.4),
                ),
                if (lead.instaId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${extractInstaUsername(lead.instaId)}',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5, color: c.coral, letterSpacing: 0.2),
                  ),
                ] else if (lead.contactNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    lead.contactNumber!,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5, color: c.muted, letterSpacing: 0.3),
                  ),
                ],
              ],
            ),
          ),
          // Edit
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 17, color: c.muted),
            tooltip: 'Edit lead',
            onPressed: () {
              Navigator.pop(context);
              showLeadDialog(context, lead);
            },
          ),
          // Close
          IconButton(
            icon: Icon(Icons.close, size: 18, color: c.muted),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─── Status + flag chips row ────────────────────────────────────────────────────

class _FlagsRow extends StatelessWidget {
  final Lead lead;
  final BLColors c;
  const _FlagsRow({required this.lead, required this.c});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(status: lead.status, c: c),
        if (lead.source != null)
          _Chip(
            icon: Icons.campaign_outlined,
            label: lead.source!.label,
            color: _sourceColor(lead.source!, c),
            bg: _sourceColor(lead.source!, c).withOpacity(0.10),
            bold: lead.source == LeadSource.instagramAd,
            c: c,
          ),
        if (lead.isOverdueFollowUp)
          _Chip(
            icon: Icons.alarm_outlined,
            label: 'Follow-up overdue',
            color: c.coral,
            bg: c.coral.withOpacity(0.08),
            c: c,
          ),
      ],
    );
  }

  Color _sourceColor(LeadSource source, BLColors c) {
    switch (source) {
      case LeadSource.instagramAd:
        return c.coral;
      case LeadSource.instagramDm:
        return c.coral.withOpacity(0.75);
      default:
        return c.muted;
    }
  }
}

/// Prominent status chip — bigger and bolder for Lost, standard for others.
class _StatusChip extends StatelessWidget {
  final LeadStatus status;
  final BLColors c;
  const _StatusChip({required this.status, required this.c});

  @override
  Widget build(BuildContext context) {
    final isLost = status == LeadStatus.lost;
    Color color;
    Color bg;
    switch (status) {
      case LeadStatus.converted:
        color = c.moss; bg = c.moss.withOpacity(0.12);
        break;
      case LeadStatus.lost:
        color = c.berry; bg = c.berry.withOpacity(0.14);
        break;
      case LeadStatus.negotiating:
      case LeadStatus.interested:
        color = c.gold; bg = c.gold.withOpacity(0.12);
        break;
      default:
        color = c.muted; bg = c.bg3;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLost ? 12 : 10, vertical: isLost ? 6 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isLost ? 0.35 : 0.2), width: isLost ? 1.2 : 1),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.interTight(
          fontSize: isLost ? 12.5 : 11.5,
          fontWeight: isLost ? FontWeight.w700 : FontWeight.w500,
          color: color,
          letterSpacing: isLost ? 0.1 : 0,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool bold;
  final BLColors c;
  const _Chip({required this.icon, required this.label, required this.color, required this.bg, required this.c, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: bold ? 12 : 10, vertical: bold ? 6 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(bold ? 0.35 : 0.2), width: bold ? 1.2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: bold ? 13 : 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.interTight(
                  fontSize: bold ? 12.5 : 11.5,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Products card ──────────────────────────────────────────────────────────────

class _ProductsCard extends StatelessWidget {
  final List<Product> products;
  final BLColors c;
  const _ProductsCard({required this.products, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Interested in', c: c),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: c.bg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.rule),
          ),
          child: Column(
            children: List.generate(products.length, (i) {
              final p = products[i];
              return Column(
                children: [
                  _ProductTile(product: p, c: c),
                  if (i < products.length - 1)
                    Divider(height: 1, color: c.rule),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final BLColors c;
  const _ProductTile({required this.product, required this.c});

  @override
  Widget build(BuildContext context) {
    final img = product.images.isNotEmpty ? product.images.first : null;
    final isNetwork = img != null && (img.startsWith('http://') || img.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 48,
              child: img == null
                  ? Container(
                      color: c.bg3,
                      child: Icon(Icons.image_not_supported_outlined, size: 20, color: c.faint),
                    )
                  : isNetwork
                      ? Image.network(img, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: c.bg3,
                            child: Icon(Icons.broken_image_outlined, size: 20, color: c.faint),
                          ))
                      : Image.asset(img, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: c.bg3,
                            child: Icon(Icons.broken_image_outlined, size: 20, color: c.faint),
                          )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.interTight(
                      fontSize: 13.5, fontWeight: FontWeight.w500, color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  product.productCode.isNotEmpty
                      ? '${product.productCode}  ·  NRS ${product.currentSellingPrice.toStringAsFixed(0)}'
                      : 'NRS ${product.currentSellingPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, color: c.muted, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
          // Stock pill
          _StockIndicator(product: product, c: c),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final Product product;
  final BLColors c;
  const _StockIndicator({required this.product, required this.c});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (product.isOutOfStock) {
      color = c.berry;
    } else if (product.isCriticalStock) {
      color = c.berry;
    } else if (product.isLowStock) {
      color = c.gold;
    } else {
      color = c.moss;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        product.stockStatus,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 9.5, fontWeight: FontWeight.w600,
            color: color, letterSpacing: 0.5),
      ),
    );
  }
}

// ─── Generic section ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  final BLColors c;
  const _Section({required this.title, required this.rows, required this.c});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: title, c: c),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: c.bg2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.rule),
          ),
          child: Column(
            children: List.generate(rows.length, (i) => Column(
              children: [
                rows[i],
                if (i < rows.length - 1) Divider(height: 1, color: c.rule),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final BLColors c;
  const _SectionLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5, color: c.muted,
          fontWeight: FontWeight.w500, letterSpacing: 1.4),
    );
  }
}

// ─── Detail row ─────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? badge;
  final Color? badgeColor;
  final bool multiLine;
  final BLColors c;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.c,
    this.valueColor,
    this.badge,
    this.badgeColor,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: c.faint),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: GoogleFonts.interTight(fontSize: 12.5, color: c.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.interTight(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? c.ink,
                height: multiLine ? 1.5 : 1.0,
              ),
            ),
          ),
          if (badge != null && badgeColor != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: badgeColor!.withOpacity(0.3)),
              ),
              child: Text(
                badge!,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: badgeColor!, letterSpacing: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
