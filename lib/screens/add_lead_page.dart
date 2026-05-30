import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../services/toast_service.dart';
import '../models/lead.dart';
import '../widgets/bl_components.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();

  // Person
  final _nameCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  LeadGender? _gender = LeadGender.female;
  String? _ageRange = '20–25';

  // Inquiry
  LeadSource? _source = LeadSource.instagramAd;
  String? _selectedProductId;
  DateTime _inquireDate = DateTime.now();
  final _budgetCtrl = TextEditingController();
  DateTime? _expectedDelivery;
  final _notesCtrl = TextEditingController();

  String _defaultNote(LeadGender? gender) {
    final pronoun = gender == LeadGender.male ? 'He' : gender == LeadGender.female ? 'She' : 'They';
    return '$pronoun inquired about the product but when we replied with the product price $pronoun didn\'t reply';
  }

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = _defaultNote(_gender);
  }

  // Tracking
  LeadStatus _status = LeadStatus.lost;
  LostReason? _lostReason = LostReason.tooExpensive;

  static const _ageRanges = [
    'No idea',
    '10–15', '15–20', '20–25', '25–30', '30–35',
    '35–40', '40–45', '45–50', '50–55', '55–60', '60+',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _instaCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _budgetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<DatabaseService>();
    final now = DateTime.now();
    final lead = Lead(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      instaId: _instaCtrl.text.trim().isEmpty ? null : _instaCtrl.text.trim(),
      contactNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      gender: _gender,
      age: _ageRange != null && _ageRange != 'No idea'
          ? int.tryParse(_ageRange!.split('–').first.replaceAll('+', ''))
          : null,
      source: _source,
      interestedProductIds: _selectedProductId != null ? [_selectedProductId!] : const [],
      budgetRange: _budgetCtrl.text.trim().isEmpty ? null : _budgetCtrl.text.trim(),
      customRequirements: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: _status,
      lostReason: _status == LeadStatus.lost ? _lostReason : null,
      inquireDate: _inquireDate,
      createdAt: now,
      updatedAt: now,
    );
    await db.addLead(lead);
    if (mounted) {
      Toaster.success(context, 'Lead added', message: lead.name);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final c = context.blColors;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyS &&
            HardwareKeyboard.instance.isMetaPressed) {
          _save();
        } else if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: c.bg,
                border: Border(bottom: BorderSide(color: c.rule)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back, size: 16, color: c.muted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('New Lead',
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: c.ink,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  Text('⌘S  save   esc  discard',
                      style: GoogleFonts.inter(
                          fontSize: 9.5, color: c.faint, letterSpacing: 0.5)),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── PERSON ───────────────────────────────────────
                            _GroupLabel('The person', c),
                            const SizedBox(height: 14),

                            // Name
                            BLInput(
                              controller: _nameCtrl,
                              label: 'Full name',
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 10),

                            // Instagram / Phone
                            Row(children: [
                              Expanded(
                                child: BLInput(
                                  controller: _instaCtrl,
                                  label: 'Instagram profile link',
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: BLInput(
                                  controller: _phoneCtrl,
                                  label: 'Phone number',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 10),

                            // Address
                            BLInput(controller: _addressCtrl, label: 'Address'),
                            const SizedBox(height: 10),

                            // Gender / Age
                            Row(children: [
                              Expanded(
                                child: _BLDropdown<LeadGender?>(
                                  label: 'Gender',
                                  value: _gender,
                                  c: c,
                                  items: [
                                    _DD(value: null, label: 'No idea', muted: true),
                                    ...LeadGender.values.map((g) => _DD(value: g, label: g.label)),
                                  ],
                                  onChanged: (v) => setState(() {
                                    // Update note if it still matches any auto-note variant
                                    final isAutoNote = LeadGender.values.any(
                                      (g) => _notesCtrl.text == _defaultNote(g),
                                    ) || _notesCtrl.text == _defaultNote(null);
                                    _gender = v;
                                    if (isAutoNote) _notesCtrl.text = _defaultNote(v);
                                  }),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BLDropdown<String?>(
                                  label: 'Age group',
                                  value: _ageRange,
                                  c: c,
                                  items: _ageRanges.map((a) => _DD(
                                    value: a == 'No idea' ? null : a,
                                    label: a,
                                    muted: a == 'No idea',
                                  )).toList(),
                                  onChanged: (v) => setState(() => _ageRange = v),
                                ),
                              ),
                            ]),

                            _Divider(c),

                            // ── INQUIRY ──────────────────────────────────────
                            _GroupLabel('What they want', c),
                            const SizedBox(height: 14),

                            // Source / Product
                            Row(children: [
                              Expanded(
                                child: _BLDropdown<LeadSource?>(
                                  label: 'Source',
                                  value: _source,
                                  c: c,
                                  items: [
                                    _DD(value: null, label: 'Unknown', muted: true),
                                    ...LeadSource.values.map((s) => _DD(value: s, label: s.label)),
                                  ],
                                  onChanged: (v) => setState(() => _source = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BLDropdown<String?>(
                                  label: 'Product interested in',
                                  value: _selectedProductId,
                                  c: c,
                                  items: [
                                    _DD(value: null, label: 'None', muted: true),
                                    ...db.products.map((p) => _DD(
                                      value: p.id,
                                      label: p.name,
                                      imageUrl: p.images.isNotEmpty ? p.images.first : null,
                                    )),
                                  ],
                                  onChanged: (v) => setState(() => _selectedProductId = v),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 10),

                            // Inquire date+time / Budget
                            Row(children: [
                              Expanded(
                                child: _DateTimeField(
                                  label: 'Inquire date & time',
                                  dateTime: _inquireDate,
                                  c: c,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: _inquireDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (d == null || !mounted) return;
                                    final t = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(_inquireDate),
                                    );
                                    setState(() {
                                      _inquireDate = DateTime(
                                        d.year, d.month, d.day,
                                        t?.hour ?? _inquireDate.hour,
                                        t?.minute ?? _inquireDate.minute,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: BLInput(
                                  controller: _budgetCtrl,
                                  label: 'Budget (NRS)',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 10),

                            // Notes
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                BLInput(
                                  controller: _notesCtrl,
                                  label: 'Notes',
                                  maxLines: 3,
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _notesCtrl.clear()),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: c.bg3,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close, size: 12, color: c.muted),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            _Divider(c),

                            // ── TRACKING ─────────────────────────────────────
                            _GroupLabel('Tracking', c),
                            const SizedBox(height: 14),

                            _BLDropdown<LeadStatus>(
                              label: 'Stage',
                              value: _status,
                              c: c,
                              items: LeadStatus.values
                                  .map((s) => _DD(value: s, label: s.label))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _status = v ?? LeadStatus.newLead),
                            ),

                            if (_status == LeadStatus.lost) ...[
                              const SizedBox(height: 10),
                              _BLDropdown<LostReason?>(
                                label: 'Why did they not buy?',
                                value: _lostReason,
                                c: c,
                                items: [
                                  _DD(value: null, label: 'Not sure', muted: true),
                                  ...LostReason.values
                                      .map((r) => _DD(value: r, label: r.label)),
                                ],
                                onChanged: (v) => setState(() => _lostReason = v),
                              ),
                            ],

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: c.bg,
                border: Border(top: BorderSide(color: c.rule)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BLButton(
                    label: 'Cancel',
                    kind: BLButtonKind.ghost,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  BLButton(
                    label: 'Add Lead',
                    kind: BLButtonKind.primary,
                    onPressed: _save,
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

// ─── Small helpers ──────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  final String text;
  final BLColors c;
  const _GroupLabel(this.text, this.c);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: c.muted,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final BLColors c;
  const _Divider(this.c);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, color: c.rule),
    );
  }
}

// ─── Date field ─────────────────────────────────────────────────────────────────

// Date + time combined field (always has a value)
class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final BLColors c;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.dateTime,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
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
            Text(
              DateFormat('MMM d, yyyy').format(dateTime),
              style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.bg3,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: c.rule),
                  ),
                  child: Text(
                    DateFormat('h:mm a').format(dateTime),
                    style: GoogleFonts.inter(
                        fontSize: 10.5, color: c.muted, letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.calendar_today_outlined, size: 14, color: c.faint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String placeholder;
  final BLColors c;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.c,
    required this.onTap,
    this.placeholder = '',
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
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
            Text(
              hasDate
                  ? DateFormat('MMM d, yyyy').format(date!)
                  : (placeholder.isEmpty ? DateFormat('MMM d, yyyy').format(DateTime.now()) : placeholder),
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: hasDate ? c.ink : c.muted,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 14, color: c.faint),
          ],
        ),
      ),
    );
  }
}

// ─── Generic dropdown ───────────────────────────────────────────────────────────

class _DD<T> {
  final T value;
  final String label;
  final bool muted;
  final String? imageUrl;
  const _DD({required this.value, required this.label, this.muted = false, this.imageUrl});
}

class _BLDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<_DD<T>> items;
  final ValueChanged<T?> onChanged;
  final BLColors c;

  const _BLDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: c.bg2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: c.rule)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: c.rule)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: c.coral, width: 1.5)),
      ),
      dropdownColor: c.bg2,
      style: GoogleFonts.inter(fontSize: 13.5, color: c.ink),
      items: items.map((dd) {
        final hasImage = dd.imageUrl != null && dd.imageUrl!.isNotEmpty;
        return DropdownMenuItem<T>(
          value: dd.value,
          child: hasImage
              ? Row(children: [
                  _MiniThumb(url: dd.imageUrl!, c: c),
                  const SizedBox(width: 8),
                  Text(dd.label,
                      style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: dd.muted ? c.muted : c.ink)),
                ])
              : Text(dd.label,
                  style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: dd.muted ? c.muted : c.ink)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _MiniThumb extends StatelessWidget {
  final String url;
  final BLColors c;
  const _MiniThumb({required this.url, required this.c});

  @override
  Widget build(BuildContext context) {
    final isNet = url.startsWith('http://') || url.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 22,
        height: 22,
        child: isNet
            ? Image.network(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: c.bg3, child: Icon(Icons.broken_image_outlined, size: 12, color: c.faint)))
            : Image.asset(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: c.bg3, child: Icon(Icons.broken_image_outlined, size: 12, color: c.faint))),
      ),
    );
  }
}
