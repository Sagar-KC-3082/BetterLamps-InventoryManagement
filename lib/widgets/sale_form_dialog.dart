import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

void showSaleDialog(BuildContext context, [Sale? sale]) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: SaleFormDialog(sale: sale),
      );
    },
  );
}

class SaleFormDialog extends StatefulWidget {
  final Sale? sale;

  const SaleFormDialog({super.key, this.sale});

  @override
  State<SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends State<SaleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String? _selectedSource;
  String _accountSettledIn = 'Sagar';
  bool _isFollowedUp = false;
  late TextEditingController _priceController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _instaIdController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late DateTime _saleDate;

  final List<String> _sourceOptions = [
    'Instagram Ad',
    'Personal Relation',
    'From Insta Feed (No Ad)',
    'Walking Customer',
    'Referral',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.sale?.productId;
    _selectedSource = widget.sale?.source;
    _accountSettledIn = widget.sale?.accountSettledIn ?? 'Sagar';
    _isFollowedUp = widget.sale?.isFollowedUp ?? false;
    _priceController =
        TextEditingController(text: widget.sale?.price.toString() ?? '');
    _nameController =
        TextEditingController(text: widget.sale?.customer.name ?? '');
    _phoneController =
        TextEditingController(text: widget.sale?.customer.phone ?? '');
    _instaIdController =
        TextEditingController(text: widget.sale?.customer.instaId ?? '');
    _addressController =
        TextEditingController(text: widget.sale?.customer.address ?? '');
    _notesController = TextEditingController(text: widget.sale?.notes ?? '');
    _saleDate = widget.sale?.saleDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _instaIdController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sale != null;
    final db = context.watch<DatabaseService>();
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.5;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.cardColor,
          border: Border(left: BorderSide(color: context.borderColor)),
          boxShadow: context.subtleShadow,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_outlined : Icons.receipt_long_outlined,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Edit Sale' : 'Record New Sale',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSecondary),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Transaction Details'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedProductId,
                        decoration: const InputDecoration(
                          labelText: 'Select Product',
                          prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                        ),
                        items: (List<Product>.from(db.products)
                              ..sort((a, b) =>
                                  a.createdDate.compareTo(b.createdDate)))
                            .map((product) {
                          return DropdownMenuItem(
                            value: product.id,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: product.images.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(product.images.first),
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 32,
                                            height: 32,
                                            color: context.surfaceColor,
                                            child: Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 16,
                                              color: context.textSecondary,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 32,
                                          height: 32,
                                          color: context.surfaceColor,
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 16,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${product.name} (NRS ${product.currentSellingPrice.toStringAsFixed(0)})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductId = value;
                            if (value != null) {
                              final product = db.getProductById(value);
                              if (product != null && _priceController.text.isEmpty) {
                                _priceController.text =
                                    product.currentSellingPrice.toString();
                              }
                            }
                          });
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Sale Price',
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
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                                ),
                                child: Text(DateFormat('MMM d, yyyy').format(_saleDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      _SectionLabel('Customer Information'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _instaIdController,
                              decoration: const InputDecoration(
                                labelText: 'Insta ID (Optional)',
                                prefixIcon: Icon(Icons.camera_alt_outlined, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      _SectionLabel('Marketing & Feedback'),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedSource,
                        decoration: const InputDecoration(
                          labelText: 'Source',
                          prefixIcon: Icon(Icons.campaign_outlined, size: 20),
                        ),
                        items: _sourceOptions.map((source) {
                          return DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedSource = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _accountSettledIn,
                        decoration: const InputDecoration(
                          labelText: 'Payment Received by',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                        ),
                        items: ['Sagar', 'Dinesh'].map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _accountSettledIn = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Followed Up?'),
                        value: _isFollowedUp,
                        onChanged: (v) => setState(() => _isFollowedUp = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 48), // Align icon to top
                            child: Icon(Icons.sticky_note_2_outlined, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.borderColor)),
                color: context.cardColor,
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor),
                          color: context.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: context.isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Submit Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _submit,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isEditing ? Icons.save_outlined : Icons.check, 
                                  size: 20, 
                                  color: Colors.white
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEditing ? 'Save Changes' : 'Record Sale',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    final db = context.read<DatabaseService>();
    final customer = Customer(
      // id: widget.sale?.customer.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      instaId: _instaIdController.text.trim().isEmpty ? null : _instaIdController.text.trim(),
      address: _addressController.text.trim(),
    );

    final sale = Sale(
      id: widget.sale?.id ?? const Uuid().v4(),
      productId: _selectedProductId!,
      customer: customer,
      saleDate: _saleDate,
      price: double.parse(_priceController.text),
      source: _selectedSource,
      isFollowedUp: _isFollowedUp,
      accountSettledIn: _accountSettledIn,
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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: context.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
