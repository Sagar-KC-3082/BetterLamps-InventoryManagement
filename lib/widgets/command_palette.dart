import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class _PaletteCommand {
  final String label;
  final String group;
  final IconData icon;
  final VoidCallback action;

  const _PaletteCommand({
    required this.label,
    required this.group,
    required this.icon,
    required this.action,
  });
}

class CommandPalette extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onToggleTheme;

  const CommandPalette({
    super.key,
    required this.onClose,
    required this.onToggleTheme,
  });

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette>
    with SingleTickerProviderStateMixin {
  final _queryCtrl = TextEditingController();
  int _selectedIndex = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late List<_PaletteCommand> _allCommands;
  List<_PaletteCommand> _filtered = [];
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
    _queryCtrl.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allCommands = [
      _PaletteCommand(label: 'Overview', group: 'Navigate', icon: Icons.dashboard_outlined, action: () { context.go('/'); widget.onClose(); }),
      _PaletteCommand(label: 'Inventory', group: 'Navigate', icon: Icons.inventory_2_outlined, action: () { context.go('/inventory'); widget.onClose(); }),
      _PaletteCommand(label: 'Filaments', group: 'Navigate', icon: Icons.layers_outlined, action: () { context.go('/filaments'); widget.onClose(); }),
      _PaletteCommand(label: 'Sales', group: 'Navigate', icon: Icons.receipt_outlined, action: () { context.go('/sales'); widget.onClose(); }),
      _PaletteCommand(label: 'Expenses', group: 'Navigate', icon: Icons.account_balance_wallet_outlined, action: () { context.go('/expenses'); widget.onClose(); }),
      _PaletteCommand(label: 'Leads', group: 'Navigate', icon: Icons.people_outline, action: () { context.go('/leads'); widget.onClose(); }),
      _PaletteCommand(label: 'Record a sale', group: 'Create', icon: Icons.add_circle_outline, action: () { context.go('/sales/new'); widget.onClose(); }),
      _PaletteCommand(label: 'Add a product', group: 'Create', icon: Icons.inventory_outlined, action: () { context.go('/inventory/new'); widget.onClose(); }),
      _PaletteCommand(label: 'Add a lead', group: 'Create', icon: Icons.person_add_outlined, action: () { context.go('/leads/new'); widget.onClose(); }),
      _PaletteCommand(label: 'Toggle dark/light', group: 'Workspace', icon: Icons.brightness_6_outlined, action: () { widget.onToggleTheme(); widget.onClose(); }),
    ];
    _filtered = List.from(_allCommands);
  }

  void _onQueryChanged() {
    final q = _queryCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allCommands)
          : _allCommands.where((c) => c.label.toLowerCase().contains(q) || c.group.toLowerCase().contains(q)).toList();
      _selectedIndex = 0;
    });
  }

  @override
  void dispose() {
    _queryCtrl.removeListener(_onQueryChanged);
    _queryCtrl.dispose();
    _animCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filtered.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + _filtered.length) % _filtered.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_filtered.isNotEmpty) {
        _filtered[_selectedIndex].action();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;

    // Group the filtered commands
    final groups = <String, List<_PaletteCommand>>{};
    for (final cmd in _filtered) {
      groups.putIfAbsent(cmd.group, () => []).add(cmd);
    }

    // Build flat index list for selection tracking
    final flatItems = <({_PaletteCommand cmd, bool isFirst, String group})>[];
    for (final entry in groups.entries) {
      bool isFirst = true;
      for (final cmd in entry.value) {
        flatItems.add((cmd: cmd, isFirst: isFirst, group: entry.key));
        isFirst = false;
      }
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: const Color(0xCC000000),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // prevent close on card tap
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 640,
                      constraints: const BoxConstraints(maxHeight: 480),
                      decoration: BoxDecoration(
                        color: c.bg2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.rule),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search input
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: c.rule),
                              ),
                            ),
                            child: TextField(
                              controller: _queryCtrl,
                              focusNode: _focusNode,
                              style: GoogleFonts.interTight(
                                fontSize: 14,
                                color: c.ink,
                                letterSpacing: -0.07,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search commands...',
                                prefixIcon: Icon(Icons.search, color: c.muted, size: 18),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                hintStyle: GoogleFonts.interTight(color: c.muted, fontSize: 14),
                                fillColor: Colors.transparent,
                                filled: true,
                              ),
                            ),
                          ),
                          // Results
                          Flexible(
                            child: flatItems.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'No commands found.',
                                      style: GoogleFonts.interTight(
                                        color: c.muted,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: flatItems.length,
                                    itemBuilder: (context, i) {
                                      final item = flatItems[i];
                                      final isSelected = i == _selectedIndex;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (item.isFirst)
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                              child: Text(
                                                item.group.toUpperCase(),
                                                style: GoogleFonts.jetBrainsMono(
                                                  fontSize: 9.5,
                                                  color: c.muted,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ),
                                          _CommandRow(
                                            cmd: item.cmd,
                                            isSelected: isSelected,
                                            onTap: item.cmd.action,
                                            onHover: (h) {
                                              if (h) setState(() => _selectedIndex = i);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          // Footer hint
                          Container(
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: c.rule)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                _KeyHint('↑↓', c),
                                const SizedBox(width: 4),
                                Text('navigate', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: c.muted)),
                                const SizedBox(width: 12),
                                _KeyHint('↵', c),
                                const SizedBox(width: 4),
                                Text('select', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: c.muted)),
                                const SizedBox(width: 12),
                                _KeyHint('esc', c),
                                const SizedBox(width: 4),
                                Text('close', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: c.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  final String label;
  final BLColors c;

  const _KeyHint(this.label, this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: c.bg3,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: c.rule2),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5,
          color: c.ink2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final _PaletteCommand cmd;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _CommandRow({
    required this.cmd,
    required this.isSelected,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? c.bg3 : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? c.coral : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(cmd.icon, size: 16, color: isSelected ? c.coral : c.muted),
              const SizedBox(width: 12),
              Text(
                cmd.label,
                style: GoogleFonts.interTight(
                  fontSize: 13.5,
                  color: isSelected ? c.ink : c.ink2,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  letterSpacing: -0.07,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
