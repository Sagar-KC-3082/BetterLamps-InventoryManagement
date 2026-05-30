import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/filament.dart';
import '../widgets/bl_components.dart';

class FilamentsScreen extends StatelessWidget {
  const FilamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    final lowStockCount = db.filaments.where((f) => f.quantity <= 3).length;
    final totalSpools = db.filaments.fold<int>(0, (s, f) => s + f.quantity);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BLPageHeader(
            breadcrumb: 'Workspace — Filaments',
            title: 'Filaments',
            actions: BLButton(
              label: 'Add Filament',
              kind: BLButtonKind.primary,
              leading: Icon(Icons.add, size: 14, color: c.ink),
              onPressed: () => _showFilamentDialog(context),
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
                  _StatCell('TYPES', db.filaments.length.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('SPOOLS', totalSpools.toString(), c),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('LOW STOCK', lowStockCount.toString(), c, isCoral: lowStockCount > 0),
                  VerticalDivider(width: 1, color: c.rule),
                  _StatCell('COST/KG', 'NRS 2,600', c),
                ],
              ),
            ),
          ),
          // Table
          Expanded(
            child: db.filaments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_outlined, size: 48, color: c.faint),
                        const SizedBox(height: 16),
                        Text('No filaments yet.',
                            style: GoogleFonts.inter(
                                fontSize: 18, color: c.muted)),
                        const SizedBox(height: 4),
                        Text('Add your first filament to start tracking.',
                            style: GoogleFonts.inter(fontSize: 13.5, color: c.muted)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Table header
                      Container(
                        color: c.bg2,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            const SizedBox(width: 50),
                            Expanded(flex: 3, child: _ColH('FILAMENT', c)),
                            Expanded(flex: 2, child: _ColH('SUPPLIER', c)),
                            Expanded(child: _ColH('COST/UNIT', c)),
                            SizedBox(width: 160, child: _ColH('QUANTITY', c, center: true)),
                            const SizedBox(width: 80),
                          ],
                        ),
                      ),
                      Divider(color: c.rule, height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: db.filaments.length,
                          separatorBuilder: (_, __) => Divider(color: c.rule, height: 1),
                          itemBuilder: (ctx, i) => _FilamentRow(filament: db.filaments[i]),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilamentDialog(BuildContext context, [Filament? filament]) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _FilamentFormDialog(filament: filament),
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
                style: GoogleFonts.inter(
                    fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.inter(
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
  final bool center;

  const _ColH(this.label, this.c, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: GoogleFonts.inter(
            fontSize: 9.5, color: c.muted, fontWeight: FontWeight.w500, letterSpacing: 1.5));
  }
}

class _FilamentRow extends StatelessWidget {
  final Filament filament;
  const _FilamentRow({required this.filament});

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final isLow = filament.quantity <= 3;

    return BLTableRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Swatch
            FilamentSwatch(color: filament.color),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${filament.type} — ${filament.color}',
                      style: GoogleFonts.inter(
                          fontSize: 13.5, color: c.ink, fontWeight: FontWeight.w500,
                          letterSpacing: -0.07)),
                  Text(DateFormat('MMM d, yyyy').format(filament.purchaseDate),
                      style: GoogleFonts.inter(
                          fontSize: 10, color: c.muted, letterSpacing: 0.3)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(filament.supplier,
                  style: GoogleFonts.inter(fontSize: 13, color: c.ink2)),
            ),
            Expanded(
              child: Text(
                'NRS ${filament.costPerUnit.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500, color: c.ink, letterSpacing: -0.3),
              ),
            ),
            // Stepper
            SizedBox(
              width: 160,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: c.rule),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepBtn(
                        icon: Icons.remove,
                        onTap: filament.quantity > 0
                            ? () => context
                                .read<DatabaseService>()
                                .updateFilamentQuantity(filament.id, filament.quantity - 1)
                            : null,
                        c: c,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${filament.quantity}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isLow ? c.coral : c.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _StepBtn(
                        icon: Icons.add,
                        onTap: () => context
                            .read<DatabaseService>()
                            .updateFilamentQuantity(filament.id, filament.quantity + 1),
                        c: c,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 16, color: c.muted),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: _FilamentFormDialog(filament: filament),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 16, color: c.berry),
                    onPressed: () => BLConfirmDialog.show(
                      context,
                      title: 'Delete filament?',
                      body: 'Delete "${filament.type} — ${filament.color}"?',
                      onConfirm: () =>
                          context.read<DatabaseService>().deleteFilament(filament.id),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final BLColors c;

  const _StepBtn({required this.icon, this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 14,
              color: onTap != null ? c.ink2 : c.faint),
        ),
      ),
    );
  }
}

class _FilamentFormDialog extends StatefulWidget {
  final Filament? filament;
  const _FilamentFormDialog({this.filament});

  @override
  State<_FilamentFormDialog> createState() => _FilamentFormDialogState();
}

class _FilamentFormDialogState extends State<_FilamentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _supplierCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _notesCtrl;
  late DateTime _purchaseDate;

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController(text: widget.filament?.type ?? '');
    _colorCtrl = TextEditingController(text: widget.filament?.color ?? '');
    _supplierCtrl = TextEditingController(text: widget.filament?.supplier ?? '');
    _costCtrl = TextEditingController(text: widget.filament?.costPerUnit.toString() ?? '');
    _quantityCtrl = TextEditingController(text: widget.filament?.quantity.toString() ?? '1');
    _notesCtrl = TextEditingController(text: widget.filament?.notes ?? '');
    _purchaseDate = widget.filament?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _colorCtrl.dispose();
    _supplierCtrl.dispose();
    _costCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<DatabaseService>();
    final f = Filament(
      id: widget.filament?.id ?? const Uuid().v4(),
      type: _typeCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      supplier: _supplierCtrl.text.trim(),
      purchaseDate: _purchaseDate,
      costPerUnit: double.tryParse(_costCtrl.text) ?? 0,
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (widget.filament != null) {
      db.updateFilament(f);
    } else {
      db.addFilament(f);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final isEdit = widget.filament != null;

    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: c.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.rule),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? 'Edit Filament' : 'Add Filament',
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w500,
                          color: c.ink, letterSpacing: -0.4)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: c.muted, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        child: BLInput(
                            controller: _typeCtrl,
                            label: 'Type',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: BLInput(
                            controller: _colorCtrl,
                            label: 'Color',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 12),
                  BLInput(
                      controller: _supplierCtrl,
                      label: 'Supplier',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _purchaseDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setState(() => _purchaseDate = d);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Purchase date',
                        filled: true,
                        fillColor: c.bg2,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide(color: c.rule)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide(color: c.rule)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d, yyyy').format(_purchaseDate),
                              style: GoogleFonts.inter(fontSize: 13.5, color: c.ink)),
                          Icon(Icons.calendar_today_outlined, size: 16, color: c.muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: BLInput(
                            controller: _costCtrl,
                            label: 'Cost/unit',
                            prefixText: 'NRS ',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: BLInput(
                            controller: _quantityCtrl,
                            label: 'Quantity',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 12),
                  BLInput(controller: _notesCtrl, label: 'Notes (optional)', maxLines: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: BLButton(
                        label: 'Cancel',
                        kind: BLButtonKind.ghost,
                        onPressed: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: BLButton(
                        label: isEdit ? 'Update' : 'Add Filament',
                        kind: BLButtonKind.primary,
                        onPressed: _submit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
