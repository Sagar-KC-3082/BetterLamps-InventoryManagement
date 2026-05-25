import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/lead.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

void showLeadDialog(BuildContext context, [Lead? lead]) {
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
        child: LeadFormDialog(lead: lead),
      );
    },
  );
}

class LeadFormDialog extends StatefulWidget {
  final Lead? lead;

  const LeadFormDialog({super.key, this.lead});

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  late TextEditingController _nameController;
  late TextEditingController _instaIdController;
  LeadGender? _selectedGender;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  late TextEditingController _alternateContactController;
  late TextEditingController _addressController;

  // Inquiry Info
  LeadSource? _selectedSource;
  List<String> _selectedInterestedProductIds = [];
  late TextEditingController _budgetController;
  bool _askedForDiscount = false;
  DateTime? _expectedDeliveryDate;
  late TextEditingController _quantityController;
  late TextEditingController _customRequirementsController;

  // Status
  LeadStatus _status = LeadStatus.newLead;

  // Purchase (driven by status)
  List<String> _purchasedProductIds = [];
  late TextEditingController _finalAmountController;
  late TextEditingController _linkedSaleIdController;
  LostReason? _lostReason;
  late TextEditingController _lostReasonNoteController;

  // Metadata
  DateTime? _inquireDate;

  bool get _isConverted => _status == LeadStatus.converted;
  bool get _isLost => _status == LeadStatus.lost;

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _nameController = TextEditingController(text: l?.name ?? '');
    _instaIdController = TextEditingController(text: l?.instaId ?? '');
    _selectedGender = l?.gender;
    _ageController =
        TextEditingController(text: l?.age != null ? '${l!.age}' : '');
    _contactController = TextEditingController(text: l?.contactNumber ?? '');
    _alternateContactController =
        TextEditingController(text: l?.alternateContact ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _selectedSource = l?.source;
    _selectedInterestedProductIds =
        List<String>.from(l?.interestedProductIds ?? []);
    _budgetController = TextEditingController(text: l?.budgetRange ?? '');
    _askedForDiscount = l?.askedForDiscount ?? false;
    _expectedDeliveryDate = l?.expectedDeliveryDate;
    _quantityController = TextEditingController(
        text: l?.quantityInterested != null ? '${l!.quantityInterested}' : '');
    _customRequirementsController =
        TextEditingController(text: l?.customRequirements ?? '');
    _status = l?.status ?? LeadStatus.newLead;
    _purchasedProductIds = List<String>.from(l?.purchasedProductIds ?? []);
    _finalAmountController = TextEditingController(
        text:
            l?.finalSellingAmount != null ? '${l!.finalSellingAmount}' : '');
    _linkedSaleIdController =
        TextEditingController(text: l?.linkedSaleId ?? '');
    _lostReason = l?.lostReason;
    _lostReasonNoteController =
        TextEditingController(text: l?.lostReasonNote ?? '');
    _inquireDate = l?.inquireDate ?? l?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instaIdController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _alternateContactController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    _quantityController.dispose();
    _customRequirementsController.dispose();
    _finalAmountController.dispose();
    _linkedSaleIdController.dispose();
    _lostReasonNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lead != null;
    final db = context.watch<DatabaseService>();
    final width = MediaQuery.of(context).size.width * 0.5;

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: context.borderColor)),
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
                          isEditing
                              ? Icons.edit_outlined
                              : Icons.person_add_outlined,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Edit Lead' : 'Add New Lead',
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

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Basic Info ──────────────────────────────
                      _SectionLabel('Basic Information'),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon:
                              Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _instaIdController,
                              decoration: const InputDecoration(
                                labelText: 'Instagram ID',
                                prefixIcon:
                                    Icon(Icons.alternate_email, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<LeadGender>(
                              value: _selectedGender,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon:
                                    Icon(Icons.wc_outlined, size: 20),
                              ),
                              items: LeadGender.values
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g.label),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon:
                                    Icon(Icons.cake_outlined, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _contactController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                                prefixIcon:
                                    Icon(Icons.phone_outlined, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _alternateContactController,
                              decoration: const InputDecoration(
                                labelText: 'Alternate Contact',
                                prefixIcon: Icon(
                                    Icons.contact_phone_outlined,
                                    size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address / Location',
                                prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Inquiry Info ────────────────────────────
                      _SectionLabel('Inquiry Details'),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<LeadSource>(
                        value: _selectedSource,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Source',
                          prefixIcon:
                              Icon(Icons.campaign_outlined, size: 20),
                        ),
                        items: LeadSource.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSource = v),
                      ),
                      const SizedBox(height: 12),

                      // Multi-select interested products
                      _ProductMultiSelect(
                        label: 'Interested Products',
                        selectedIds: _selectedInterestedProductIds,
                        products: db.products,
                        onChanged: (ids) =>
                            setState(() => _selectedInterestedProductIds = ids),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _budgetController,
                              decoration: const InputDecoration(
                                labelText: 'Budget Range',
                                prefixText: 'NRS ',
                                prefixIcon: Icon(
                                    Icons.attach_money_outlined,
                                    size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity Interested',
                                prefixIcon: Icon(
                                    Icons.production_quantity_limits_outlined,
                                    size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _DatePickerField(
                        label: 'Inquire Date',
                        value: _inquireDate,
                        onChanged: (d) => setState(() => _inquireDate = d),
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Asked for discount?'),
                        value: _askedForDiscount,
                        onChanged: (v) => setState(() => _askedForDiscount = v),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _customRequirementsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.sticky_note_2_outlined,
                                size: 20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Status ──────────────────────────────────
                      _SectionLabel('Status & Tracking'),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<LeadStatus>(
                        value: _status,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Inquiry Status',
                          prefixIcon: Icon(
                              Icons.flag_outlined, size: 20),
                        ),
                        items: LeadStatus.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _status = v);
                        },
                      ),
                      const SizedBox(height: 12),

                      // ── Outcome — shown when Converted or Lost ──
                      if (_isConverted) ...[
                        const SizedBox(height: 24),
                        _SectionLabel('Purchase Outcome'),
                        const SizedBox(height: 12),
                        _ProductMultiSelect(
                          label: 'Purchased Products',
                          selectedIds: _purchasedProductIds,
                          products: db.products,
                          onChanged: (ids) =>
                              setState(() => _purchasedProductIds = ids),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _finalAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Final Selling Amount',
                                  prefixText: 'NRS ',
                                  prefixIcon: Icon(Icons.payments_outlined, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _linkedSaleIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Linked Sale ID (optional)',
                                  prefixIcon: Icon(Icons.link_outlined, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (_isLost) ...[
                        const SizedBox(height: 24),
                        _SectionLabel('Lost Details'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<LostReason>(
                          value: _lostReason,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Reason Lost',
                            prefixIcon: Icon(Icons.sentiment_dissatisfied_outlined, size: 20),
                          ),
                          items: LostReason.values
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                              .toList(),
                          onChanged: (v) => setState(() => _lostReason = v),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: context.borderColor)),
                color: context.cardColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: context.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: context.textPrimary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing
                                  ? Icons.save_outlined
                                  : Icons.check,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Save Changes' : 'Add Lead',
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
    final now = DateTime.now();

    final lead = Lead(
      id: widget.lead?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      instaId: _instaIdController.text.trim().isEmpty
          ? null
          : _instaIdController.text.trim(),
      gender: _selectedGender,
      age: _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim()),
      contactNumber: _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
      alternateContact: _alternateContactController.text.trim().isEmpty
          ? null
          : _alternateContactController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      source: _selectedSource,
      interestedProductIds: _selectedInterestedProductIds,
      budgetRange: _budgetController.text.trim().isEmpty
          ? null
          : _budgetController.text.trim(),
      askedForDiscount: _askedForDiscount,
      expectedDeliveryDate: _expectedDeliveryDate,
      quantityInterested: _quantityController.text.trim().isEmpty
          ? null
          : int.tryParse(_quantityController.text.trim()),
      customRequirements: _customRequirementsController.text.trim().isEmpty
          ? null
          : _customRequirementsController.text.trim(),
      status: _status,
      didBuy: _isConverted,
      purchasedProductIds: _isConverted ? _purchasedProductIds : [],
      finalSellingAmount: _finalAmountController.text.trim().isEmpty
          ? null
          : double.tryParse(_finalAmountController.text.trim()),
      linkedSaleId: _linkedSaleIdController.text.trim().isEmpty
          ? null
          : _linkedSaleIdController.text.trim(),
      lostReason: _isLost ? _lostReason : null,
      lostReasonNote: _isLost && _lostReasonNoteController.text.trim().isNotEmpty
          ? _lostReasonNoteController.text.trim()
          : null,
      inquireDate: _inquireDate,
      createdAt: widget.lead?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.lead != null) {
      db.updateLead(lead);
    } else {
      db.addLead(lead);
    }

    Navigator.pop(context);
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────

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

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowFuture;

  const _DatePickerField({
    required this.label,
    this.value,
    required this.onChanged,
    this.allowFuture = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: allowFuture
              ? DateTime.now().add(const Duration(days: 365))
              : DateTime.now().add(const Duration(days: 1)),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_today_outlined, size: 20),
        ),
        child: Text(
          value != null
              ? DateFormat('MMM d, yyyy').format(value!)
              : 'Not set',
          style: TextStyle(
            fontSize: 14,
            color: value != null
                ? context.textPrimary
                : context.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _ProductMultiSelect extends StatelessWidget {
  final String label;
  final List<String> selectedIds;
  final List<dynamic> products;
  final ValueChanged<List<String>> onChanged;

  const _ProductMultiSelect({
    required this.label,
    required this.selectedIds,
    required this.products,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showPicker(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon:
                  const Icon(Icons.inventory_2_outlined, size: 20),
              suffixIcon:
                  const Icon(Icons.expand_more_outlined, size: 20),
            ),
            child: Text(
              selectedIds.isEmpty
                  ? 'None selected'
                  : '${selectedIds.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: selectedIds.isEmpty
                    ? context.textSecondary.withOpacity(0.6)
                    : context.textPrimary,
              ),
            ),
          ),
        ),
        if (selectedIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedIds.map((id) {
              final product = products.cast<dynamic>().firstWhere(
                (p) => p.id == id,
                orElse: () => null,
              );
              final name = product?.name as String? ?? id;
              return Chip(
                label: Text(name,
                    style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  final updated = List<String>.from(selectedIds)
                    ..remove(id);
                  onChanged(updated);
                },
                deleteIconColor: context.textSecondary,
                backgroundColor:
                    context.primaryColor.withOpacity(0.08),
                side: BorderSide(
                    color: context.primaryColor.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ProductPickerDialog(
        selectedIds: selectedIds,
        products: products,
        onChanged: onChanged,
      ),
    );
  }
}

class _ProductPickerDialog extends StatefulWidget {
  final List<String> selectedIds;
  final List<dynamic> products;
  final ValueChanged<List<String>> onChanged;

  const _ProductPickerDialog({
    required this.selectedIds,
    required this.products,
    required this.onChanged,
  });

  @override
  State<_ProductPickerDialog> createState() =>
      _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<_ProductPickerDialog> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Products'),
      content: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          children: widget.products.map<Widget>((product) {
            final isSelected = _selected.contains(product.id);
            return CheckboxListTile(
              value: isSelected,
              title: Text(product.name),
              subtitle: Text(
                  'NRS ${product.currentSellingPrice.toStringAsFixed(0)}'),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(product.id);
                  } else {
                    _selected.remove(product.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onChanged(_selected);
            Navigator.pop(context);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
