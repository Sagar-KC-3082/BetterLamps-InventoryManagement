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
import '../models/expense.dart';
import '../widgets/bl_components.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final _nameCtrl = TextEditingController();
  final _personCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _personCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<DatabaseService>();
    final expense = Expense(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      person: _personCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await db.addExpense(expense);
    if (mounted) {
      Toaster.success(context, 'Expense added', message: expense.name);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              decoration: BoxDecoration(
                color: c.bg2,
                border: Border(bottom: BorderSide(color: c.rule, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 18, color: c.muted),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('Add Expense',
                      style: GoogleFonts.newsreader(
                          fontSize: 20, fontWeight: FontWeight.w500,
                          color: c.ink, letterSpacing: -0.4)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 560,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date picker
                          InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 1)),
                              );
                              if (d != null) setState(() => _date = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
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
                                  Text(DateFormat('MMM d, yyyy').format(_date),
                                      style: GoogleFonts.interTight(fontSize: 13.5, color: c.ink)),
                                  Icon(Icons.calendar_today_outlined, size: 16, color: c.muted),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BLInput(
                              controller: _nameCtrl,
                              label: 'Description',
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: BLInput(
                                  controller: _personCtrl,
                                  label: 'Person / Category',
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BLInput(
                                  controller: _amountCtrl,
                                  label: 'Amount',
                                  prefixText: 'NRS ',
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          BLInput(controller: _notesCtrl, label: 'Notes (optional)', maxLines: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: c.bg2,
                border: Border(top: BorderSide(color: c.rule, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                children: [
                  Text('⌘S save  ·  esc discard',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: c.muted, letterSpacing: 0.5)),
                  const Spacer(),
                  BLButton(label: 'Cancel', kind: BLButtonKind.ghost, onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  BLButton(label: 'Add Expense', kind: BLButtonKind.primary, onPressed: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
