import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/filament.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class FilamentsScreen extends StatelessWidget {
  const FilamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filaments',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your filament inventory',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: context.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: context.brandShadow,
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showFilamentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add Filament'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Stats
          Consumer<DatabaseService>(
            builder: (context, db, child) {
              return Row(
                children: [
                  _StatCard(
                    label: 'Total Types',
                    value: db.filaments.length.toString(),
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    label: 'Total Stock',
                    value: db.totalFilamentStock.toString(),
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    label: 'Low Stock',
                    value: db.filaments.where((f) => f.quantity < 10).length.toString(),
                    isWarning: db.filaments.any((f) => f.quantity < 10),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          // Table Header
          Consumer<DatabaseService>(
            builder: (context, db, child) {
              if (db.filaments.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 48,
                          color: context.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No filaments yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add your first filament to track',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: context.surfaceColor.withOpacity(0.5),
                          border: Border(
                            bottom: BorderSide(color: context.borderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 44),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Filament',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Supplier',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Cost',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 140,
                              child: Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF737373),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 80),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: db.filaments.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: context.borderColor,
                          ),
                          itemBuilder: (context, index) {
                            return _FilamentRow(filament: db.filaments[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _StatCard({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? context.warningColor.withOpacity(0.3) : context.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isWarning ? context.warningColor : context.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilamentRow extends StatefulWidget {
  final Filament filament;

  const _FilamentRow({required this.filament});

  @override
  State<_FilamentRow> createState() => _FilamentRowState();
}

class _FilamentRowState extends State<_FilamentRow> {
  bool _isHovered = false;

  Color _getColorFromName(String colorName) {
    final colors = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.amber,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'black': Colors.grey.shade800,
      'white': Colors.grey.shade300,
      'brown': Colors.brown,
      'gold': Colors.amber.shade600,
      'silver': Colors.blueGrey,
      'warm white': Colors.orange.shade200,
      'cool white': Colors.blue.shade100,
    };
    return colors[colorName.toLowerCase()] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = widget.filament.quantity < 10;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered
            ? (context.isDarkMode
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.01))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getColorFromName(widget.filament.color),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  widget.filament.type[0].toUpperCase(),
                  style: TextStyle(
                    color: _getColorFromName(widget.filament.color).computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.filament.type} - ${widget.filament.color}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(widget.filament.purchaseDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Supplier
            Expanded(
              flex: 2,
              child: Text(
                widget.filament.supplier,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ),
            // Cost
            Expanded(
              child: Text(
                'NRS ${widget.filament.costPerUnit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
            // Quantity
            SizedBox(
              width: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: widget.filament.quantity > 0
                        ? () => context.read<DatabaseService>().updateFilamentQuantity(
                            widget.filament.id, widget.filament.quantity - 1)
                        : null,
                  ),
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? context.errorBgColor
                          : (context.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.filament.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isLowStock ? context.errorColor : context.textPrimary,
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: () => context.read<DatabaseService>().updateFilamentQuantity(
                        widget.filament.id, widget.filament.quantity + 1),
                  ),
                ],
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: _isHovered
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18, color: context.textSecondary),
                          onPressed: () => _editFilament(context),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: context.errorColor),
                          onPressed: () => _deleteFilament(context),
                          visualDensity: VisualDensity.compact,
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

  void _editFilament(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _FilamentFormDialog(filament: widget.filament),
      ),
    );
  }

  void _deleteFilament(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Filament'),
        content: Text('Delete "${widget.filament.type} - ${widget.filament.color}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DatabaseService>().deleteFilament(widget.filament.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: onTap != null
                ? context.textPrimary
                : context.textSecondary.withOpacity(0.3),
          ),
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
  late TextEditingController _typeController;
  late TextEditingController _colorController;
  late TextEditingController _supplierController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late DateTime _purchaseDate;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.filament?.type ?? '');
    _colorController = TextEditingController(text: widget.filament?.color ?? '');
    _supplierController = TextEditingController(text: widget.filament?.supplier ?? '');
    _costController = TextEditingController(text: widget.filament?.costPerUnit.toString() ?? '');
    _quantityController = TextEditingController(text: widget.filament?.quantity.toString() ?? '');
    _notesController = TextEditingController(text: widget.filament?.notes ?? '');
    _purchaseDate = widget.filament?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _colorController.dispose();
    _supplierController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.filament != null;

    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Filament' : 'Add Filament',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSecondary, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: context.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(labelText: 'Type'),
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: const InputDecoration(labelText: 'Color'),
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _supplierController,
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _purchaseDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _purchaseDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Purchase Date'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d, yyyy').format(_purchaseDate)),
                          Icon(Icons.calendar_today_outlined,
                              size: 18, color: context.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Cost/Unit',
                            prefixText: 'NRS ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(v!) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(v!) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: context.textPrimary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: context.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: context.brandShadow,
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update' : 'Add Filament', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final db = context.read<DatabaseService>();
    final filament = Filament(
      id: widget.filament?.id ?? const Uuid().v4(),
      type: _typeController.text.trim(),
      color: _colorController.text.trim(),
      supplier: _supplierController.text.trim(),
      purchaseDate: _purchaseDate,
      costPerUnit: double.parse(_costController.text),
      quantity: int.parse(_quantityController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.filament != null) {
      db.updateFilament(filament);
    } else {
      db.addFilament(filament);
    }

    Navigator.pop(context);
  }
}
