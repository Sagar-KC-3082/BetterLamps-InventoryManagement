import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
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
                      'Sales',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your lamp sales and customers',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Consumer<DatabaseService>(
                  builder: (context, db, child) {
                    return _AddButton(
                      label: 'Record Sale',
                      onPressed: db.products.isEmpty ? () => _showNoProductsDialog(context) : () => _showSaleDialog(context),
                    );
                  },
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
                      icon: Icons.receipt_long,
                      label: 'Total Sales',
                      value: db.totalSalesCount.toString(),
                      color: const Color(0xFF4CAF50),
                      delay: 0,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.attach_money,
                      label: 'Total Revenue',
                      value: '\$${db.totalSalesAmount.toStringAsFixed(0)}',
                      color: const Color(0xFF2196F3),
                      delay: 100,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.trending_up,
                      label: 'Avg. Sale',
                      value: db.sales.isEmpty ? '\$0' : '\$${(db.totalSalesAmount / db.sales.length).toStringAsFixed(0)}',
                      color: const Color(0xFF9C27B0),
                      delay: 200,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            // Sales List
            Expanded(
              child: Consumer<DatabaseService>(
                builder: (context, db, child) {
                  if (db.sales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.receipt_long, size: 64, color: Colors.green.shade300),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No sales yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2E)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            db.products.isEmpty ? 'Add products first, then record sales' : 'Record your first sale to get started',
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
                        itemCount: db.sales.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final sale = db.sales[index];
                          final product = db.getProductById(sale.productId);
                          return _SaleRow(sale: sale, product: product, index: index);
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

  void _showNoProductsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'No Products',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('No Products'),
              content: const Text('Please add products first before recording a sale.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSaleDialog(BuildContext context, [Sale? sale]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sale Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Center(child: _SaleFormDialog(sale: sale)),
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

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.delay});

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
                decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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

class _SaleRow extends StatefulWidget {
  final Sale sale;
  final Product? product;
  final int index;

  const _SaleRow({required this.sale, this.product, required this.index});

  @override
  State<_SaleRow> createState() => _SaleRowState();
}

class _SaleRowState extends State<_SaleRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isExpanded = false;

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

  Widget _buildProductImage() {
    if (widget.product != null && widget.product!.images.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(base64Decode(widget.product!.images.first), width: 48, height: 48, fit: BoxFit.cover),
        );
      } catch (e) {
        return _defaultImage();
      }
    }
    return _defaultImage();
  }

  Widget _defaultImage() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.orange.shade50]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.lightbulb, color: Colors.orange.shade300, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _isHovered ? Colors.grey.shade50 : Colors.white,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        _buildProductImage(),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.product?.name ?? 'Unknown Product',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E1E2E))),
                              const SizedBox(height: 2),
                              Text(widget.sale.customer.name, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Expanded(child: Text(dateFormat.format(widget.sale.saleDate), style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
                        Expanded(
                          child: Text(widget.sale.customer.phone.isNotEmpty ? widget.sale.customer.phone : '-',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Text('\$${widget.sale.price.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        ),
                        const SizedBox(width: 16),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                        ),
                        if (_isHovered) ...[
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: Colors.grey.shade600, onPressed: () => _editSale(context)),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 20), color: Colors.red.shade400, onPressed: () => _deleteSale(context)),
                        ],
                      ],
                    ),
                  ),
                ),
                // Expanded details
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer Details', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)),
                                const SizedBox(height: 8),
                                _DetailItem('Name', widget.sale.customer.name),
                                _DetailItem('Phone', widget.sale.customer.phone),
                                _DetailItem('Email', widget.sale.customer.email),
                                _DetailItem('Address', widget.sale.customer.address),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sale Details', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)),
                                const SizedBox(height: 8),
                                _DetailItem('Product', widget.product?.name ?? 'Unknown'),
                                _DetailItem('Date', dateFormat.format(widget.sale.saleDate)),
                                _DetailItem('Price', '\$${widget.sale.price.toStringAsFixed(2)}'),
                                if (widget.sale.notes != null && widget.sale.notes!.isNotEmpty) _DetailItem('Notes', widget.sale.notes!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editSale(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Sale',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: Center(child: _SaleFormDialog(sale: widget.sale))),
        );
      },
    );
  }

  void _deleteSale(BuildContext context) {
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
              title: const Text('Delete Sale'),
              content: Text('Delete sale to "${widget.sale.customer.name}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
                ElevatedButton(
                  onPressed: () {
                    context.read<DatabaseService>().deleteSale(widget.sale.id);
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

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text('$label:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(color: Color(0xFF1E1E2E), fontSize: 13))),
        ],
      ),
    );
  }
}

class _SaleFormDialog extends StatefulWidget {
  final Sale? sale;

  const _SaleFormDialog({this.sale});

  @override
  State<_SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends State<_SaleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  late TextEditingController _priceController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late DateTime _saleDate;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.sale?.productId;
    _priceController = TextEditingController(text: widget.sale?.price.toString() ?? '');
    _nameController = TextEditingController(text: widget.sale?.customer.name ?? '');
    _phoneController = TextEditingController(text: widget.sale?.customer.phone ?? '');
    _emailController = TextEditingController(text: widget.sale?.customer.email ?? '');
    _addressController = TextEditingController(text: widget.sale?.customer.address ?? '');
    _notesController = TextEditingController(text: widget.sale?.notes ?? '');
    _saleDate = widget.sale?.saleDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sale != null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final db = context.watch<DatabaseService>();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEditing ? 'Edit Sale' : 'Record Sale',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Product', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProductId,
                  decoration: const InputDecoration(hintText: 'Select a product'),
                  items: db.products.map((product) {
                    return DropdownMenuItem(value: product.id, child: Text('${product.name} (\$${product.basePrice.toStringAsFixed(2)})'));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                      if (value != null) {
                        final product = db.getProductById(value);
                        if (product != null && _priceController.text.isEmpty) {
                          _priceController.text = product.basePrice.toString();
                        }
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Please select a product' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Sale Price', prefixText: '\$ '),
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
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _saleDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 1)),
                          );
                          if (date != null) setState(() => _saleDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Sale Date'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(dateFormat.format(_saleDate)), Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Customer Information', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
                const SizedBox(height: 16),
                TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
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
                        child: Text(isEditing ? 'Update Sale' : 'Record Sale'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final db = context.read<DatabaseService>();
    final sale = Sale(
      id: widget.sale?.id ?? const Uuid().v4(),
      saleDate: _saleDate,
      productId: _selectedProductId!,
      price: double.parse(_priceController.text),
      customer: Customer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
      ),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.sale != null) {
      db.updateSale(sale);
    } else {
      db.addSale(sale);
    }

    Navigator.pop(context);
  }
}
