import 'dart:convert';
import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// BLStatusPill
// ---------------------------------------------------------------------------

enum BLStatusKind { healthy, low, warn, berry, neutral }

class BLStatusPill extends StatelessWidget {
  final String label;
  final BLStatusKind kind;

  const BLStatusPill({super.key, required this.label, this.kind = BLStatusKind.neutral});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    Color dotColor;
    Color bgColor;
    Color textColor;

    switch (kind) {
      case BLStatusKind.healthy:
        dotColor = c.moss;
        bgColor = c.moss.withOpacity(0.12);
        textColor = c.moss;
        break;
      case BLStatusKind.low:
        dotColor = c.coral;
        bgColor = c.coralSoft;
        textColor = c.coral;
        break;
      case BLStatusKind.warn:
        dotColor = c.gold;
        bgColor = c.gold.withOpacity(0.12);
        textColor = c.gold;
        break;
      case BLStatusKind.berry:
        dotColor = c.berry;
        bgColor = c.berry.withOpacity(0.12);
        textColor = c.berry;
        break;
      case BLStatusKind.neutral:
        dotColor = c.muted;
        bgColor = c.bg3;
        textColor = c.ink2;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLStockBar
// ---------------------------------------------------------------------------

class BLStockBar extends StatelessWidget {
  final int available;
  final int total;

  const BLStockBar({super.key, required this.available, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final ratio = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;
    final isLow = ratio < 0.4;

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: c.rule,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: isLow ? c.coral : c.moss,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$available',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isLow ? c.coral : c.ink2,
                  letterSpacing: -0.06,
                ),
              ),
              TextSpan(
                text: '/$total',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: c.muted,
                  letterSpacing: -0.06,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// BLSectionCard
// ---------------------------------------------------------------------------

class BLSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BLSectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.rule, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.ink,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Divider(color: c.rule, height: 24, thickness: 1),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLPageHeader
// ---------------------------------------------------------------------------

class BLPageHeader extends StatelessWidget {
  final String breadcrumb;
  final String title;
  final String? subtitle;
  final Widget? actions;

  const BLPageHeader({
    super.key,
    required this.breadcrumb,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breadcrumb.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: c.muted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: c.ink,
                    letterSpacing: -0.65,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: c.muted,
                      letterSpacing: -0.07,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) actions!,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLFilterRail
// ---------------------------------------------------------------------------

class BLFilterGroup {
  final String label;
  final List<BLFilterItem> items;

  const BLFilterGroup({required this.label, required this.items});
}

class BLFilterItem {
  final String label;
  final bool isAction;

  const BLFilterItem({required this.label, this.isAction = false});
}

class BLFilterRail extends StatelessWidget {
  final List<BLFilterGroup> groups;
  final String? selectedItem;
  final void Function(String group, String item) onSelect;

  const BLFilterRail({
    super.key,
    required this.groups,
    required this.onSelect,
    this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: c.rule, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groups.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Text(
                    group.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ...group.items.map((item) {
                  final isSelected = selectedItem == item.label;
                  return _FilterRow(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onSelect(group.label, item.label),
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterRow extends StatefulWidget {
  final BLFilterItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? c.bg2
                : (_hovered ? c.bgHover : Colors.transparent),
            border: Border(
              left: BorderSide(
                color: widget.isSelected ? c.coral : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.item.label,
            style: widget.item.isAction
                ? GoogleFonts.inter(
                    fontSize: 13.5,
                    color: c.coral,
                    letterSpacing: -0.2,
                  )
                : GoogleFonts.inter(
                    fontSize: 13.5,
                    color: widget.isSelected ? c.ink : c.ink2,
                    fontWeight: widget.isSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                    letterSpacing: -0.07,
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLTableRow
// ---------------------------------------------------------------------------

class BLTableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BLTableRow({super.key, required this.child, this.onTap});

  @override
  State<BLTableRow> createState() => _BLTableRowState();
}

class _BLTableRowState extends State<BLTableRow>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _ctrl;
  late Animation<double> _edge;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _edge = Tween<double>(begin: 0, end: 3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _edge,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: _hovered ? c.bgHover : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: c.coral.withOpacity(_edge.value / 3),
                    width: _edge.value,
                  ),
                  bottom: BorderSide(color: c.rule, width: 1),
                ),
              ),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MoneyText
// ---------------------------------------------------------------------------

class MoneyText extends StatelessWidget {
  final double amount;
  final bool positive;
  final double fontSize;

  const MoneyText({
    super.key,
    required this.amount,
    this.positive = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final color = positive ? c.coral : c.ink;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'NRS ',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: c.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: amount.toStringAsFixed(0),
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color,
              
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLInput
// ---------------------------------------------------------------------------

class BLInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? prefixText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const BLInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final monoStyle = GoogleFonts.inter(
      fontSize: 11,
      color: c.muted,
      fontWeight: FontWeight.w500,
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        color: c.ink,
        letterSpacing: -0.07,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: monoStyle,
        suffixStyle: monoStyle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLButton
// ---------------------------------------------------------------------------

enum BLButtonKind { primary, ghost, danger }

class BLButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BLButtonKind kind;
  final Widget? leading;

  const BLButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = BLButtonKind.primary,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;

    Color bg;
    Color fg;
    Color borderColor;

    switch (kind) {
      case BLButtonKind.primary:
        bg = c.coral;
        fg = c.ink;
        borderColor = c.coral;
        break;
      case BLButtonKind.ghost:
        bg = Colors.transparent;
        fg = c.ink2;
        borderColor = c.rule;
        break;
      case BLButtonKind.danger:
        bg = c.berry;
        fg = c.ink;
        borderColor = c.berry;
        break;
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderColor),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.07,
        ),
      ),
      child: leading != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leading!,
                const SizedBox(width: 6),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

// ---------------------------------------------------------------------------
// BLConfirmDialog
// ---------------------------------------------------------------------------

class BLConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const BLConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    this.confirmLabel = 'Delete',
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Delete',
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => BLConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return Dialog(
      backgroundColor: c.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.rule),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: c.ink,
                  letterSpacing: -0.33,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: c.ink2,
                  letterSpacing: -0.07,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BLButton(
                    label: 'Cancel',
                    kind: BLButtonKind.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  BLButton(
                    label: confirmLabel,
                    kind: BLButtonKind.danger,
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BLWorkspace
// ---------------------------------------------------------------------------

class BLWorkspace extends StatelessWidget {
  final Widget filterRail;
  final Widget dataPane;

  const BLWorkspace({
    super.key,
    required this.filterRail,
    required this.dataPane,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filterRail,
        Expanded(child: dataPane),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Filament Swatch helper
// ---------------------------------------------------------------------------

class FilamentSwatch extends StatelessWidget {
  final String color;
  final double size;

  const FilamentSwatch({super.key, required this.color, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final isCharcoal = color.toLowerCase().contains('charcoal') ||
        color.toLowerCase().contains('black');

    final gradient = isCharcoal
        ? const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF555555)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFF5EDD5), Color(0xFFDDCFB0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ProductThumb — product image thumbnail with letter fallback
// ---------------------------------------------------------------------------

class ProductThumb extends StatelessWidget {
  final Product? product;
  final double size;
  final double radius;

  const ProductThumb({
    super.key,
    required this.product,
    this.size = 32,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final name = product?.name ?? '';
    final images = product?.images ?? [];

    Widget imageWidget;
    if (images.isNotEmpty) {
      final raw = images.first;
      try {
        final b64 = raw.contains(',') ? raw.split(',').last : raw;
        final bytes = base64Decode(b64);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letterFallback(name, c));
      } catch (_) {
        imageWidget = _letterFallback(name, c);
      }
    } else {
      imageWidget = _letterFallback(name, c);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: c.bg3,
        child: imageWidget,
      ),
    );
  }

  Widget _letterFallback(String name, BLColors c) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.inter(
          fontSize: size * 0.42,
          color: c.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
