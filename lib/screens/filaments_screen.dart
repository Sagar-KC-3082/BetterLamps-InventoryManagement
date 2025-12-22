import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/filament.dart';
import '../services/database_service.dart';

class FilamentsScreen extends StatefulWidget {
  const FilamentsScreen({super.key});

  @override
  State<FilamentsScreen> createState() => _FilamentsScreenState();
}

class _FilamentsScreenState extends State<FilamentsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
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
                    const Text(
                      'Filaments',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your filament inventory stock',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                _AddButton(
                  label: 'Add Filament',
                  onPressed: () => _showFilamentDialog(context),
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
                      icon: Icons.category,
                      label: 'Total Types',
                      value: db.filaments.length.toString(),
                      color: const Color(0xFF2196F3),
                      delay: 0,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.inventory,
                      label: 'Total Stock',
                      value: db.totalFilamentStock.toString(),
                      color: const Color(0xFF9C27B0),
                      delay: 100,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.warning_amber,
                      label: 'Low Stock',
                      value: db.filaments.where((f) => f.quantity < 10).length.toString(),
                      color: const Color(0xFFFF5722),
                      delay: 200,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            // Filaments Table
            Expanded(
              child: Consumer<DatabaseService>(
                builder: (context, db, child) {
                  if (db.filaments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.cable, size: 64, color: Colors.blue.shade300),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No filaments yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2E)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first filament to track inventory',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: db.filaments.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          return _FilamentRow(
                            filament: db.filaments[index],
                            index: index,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilamentDialog(BuildContext context, [Filament? filament]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filament Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Center(child: _FilamentFormDialog(filament: filament)),
          ),
        );
      },
    );
  }
}

class _AddButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: _isHovered ? 8 : 2,
            shadowColor: const Color(0xFFFF9800).withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E))),
                  Text(widget.label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilamentRow extends StatefulWidget {
  final Filament filament;
  final int index;

  const _FilamentRow({required this.filament, required this.index});

  @override
  State<_FilamentRow> createState() => _FilamentRowState();
}

class _FilamentRowState extends State<_FilamentRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorFromName(String colorName) {
    final colors = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow.shade700,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'black': Colors.black87,
      'white': Colors.grey.shade400,
      'brown': Colors.brown,
      'gold': Colors.amber,
      'silver': Colors.blueGrey,
      'warm white': Colors.amber.shade200,
      'cool white': Colors.lightBlue.shade100,
    };
    return colors[colorName.toLowerCase()] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isLowStock = widget.filament.quantity < 10;

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _isHovered ? Colors.grey.shade50 : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColorFromName(widget.filament.color),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getColorFromName(widget.filament.color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.filament.type[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.filament.type} - ${widget.filament.color}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E1E2E)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.filament.supplier,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                // Date
                Expanded(
                  child: Text(
                    dateFormat.format(widget.filament.purchaseDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
                // Price
                Expanded(
                  child: Text(
                    '\$${widget.filament.costPerUnit.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E1E2E)),
                  ),
                ),
                // Quantity controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowStock ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: widget.filament.quantity > 0
                            ? () => context.read<DatabaseService>().updateFilamentQuantity(widget.filament.id, widget.filament.quantity - 1)
                            : null,
                      ),
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.filament.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isLowStock ? Colors.red : const Color(0xFF1E1E2E),
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => context.read<DatabaseService>().updateFilamentQuantity(widget.filament.id, widget.filament.quantity + 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Actions
                if (_isHovered) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: Colors.grey.shade600,
                    onPressed: () => _editFilament(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red.shade400,
                    onPressed: () => _deleteFilament(context),
                  ),
                ] else
                  const SizedBox(width: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editFilament(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Filament',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Center(child: _FilamentFormDialog(filament: widget.filament)),
          ),
        );
      },
    );
  }

  void _deleteFilament(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Delete Filament'),
              content: Text('Delete "${widget.filament.type} - ${widget.filament.color}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
                ElevatedButton(
                  onPressed: () {
                    context.read<DatabaseService>().deleteFilament(widget.filament.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: onTap != null ? const Color(0xFF1E1E2E) : Colors.grey.shade400),
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
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Filament' : 'Add Filament',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Type', hintText: 'e.g., LED, Incandescent'),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Color', hintText: 'e.g., Warm White'),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Supplier', hintText: 'Supplier name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
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
                      Text(dateFormat.format(_purchaseDate)),
                      Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(labelText: 'Cost/Unit', prefixText: '\$ '),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEditing ? 'Update' : 'Add Filament'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
