import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/toast_service.dart';
import 'theme/app_theme.dart';
import 'widgets/command_palette.dart';
import 'screens/overview_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/filaments_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/leads_screen.dart';
import 'screens/add_product_page.dart';
import 'screens/record_sale_page.dart';
import 'screens/add_expense_page.dart';
import 'screens/add_lead_page.dart';

// ---------------------------------------------------------------------------
// Theme persistence
// ---------------------------------------------------------------------------

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode;

  ThemeNotifier(this._mode);

  ThemeMode get themeMode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    _persist();
  }

  void setMode(ThemeMode m) {
    _mode = m;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bl_mode', _mode == ThemeMode.dark ? 'dark' : 'light');
  }

  static Future<ThemeNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bl_mode');
    final mode = raw == 'dark' ? ThemeMode.dark : ThemeMode.light;
    return ThemeNotifier(mode);
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const OverviewScreen()),
        GoRoute(
          path: '/inventory',
          builder: (_, __) => const InventoryScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const AddProductPage()),
          ],
        ),
        GoRoute(path: '/filaments', builder: (_, __) => const FilamentsScreen()),
        GoRoute(
          path: '/sales',
          builder: (_, __) => const SalesScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const RecordSalePage()),
          ],
        ),
        GoRoute(
          path: '/expenses',
          builder: (_, __) => const ExpensesScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const AddExpensePage()),
          ],
        ),
        GoRoute(
          path: '/leads',
          builder: (_, __) => const LeadsScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const AddLeadPage()),
          ],
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// main()
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final databaseService = DatabaseService();
  await databaseService.init();

  final themeNotifier = await ThemeNotifier.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: databaseService),
        ChangeNotifierProvider.value(value: themeNotifier),
      ],
      child: const BetterLampsApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// BetterLampsApp
// ---------------------------------------------------------------------------

class BetterLampsApp extends StatelessWidget {
  const BetterLampsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp.router(
      title: 'Better Lamps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      routerConfig: _router,
      builder: (context, child) => ToastOverlay(child: child ?? const SizedBox()),
    );
  }
}

// ---------------------------------------------------------------------------
// _AppShell
// ---------------------------------------------------------------------------

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  bool _paletteOpen = false;

  void _openPalette() => setState(() => _paletteOpen = true);
  void _closePalette() => setState(() => _paletteOpen = false);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyK &&
            HardwareKeyboard.instance.isMetaPressed) {
          _openPalette();
        }
      },
      child: Scaffold(
        backgroundColor: context.blColors.bg,
        body: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  onSearchTap: _openPalette,
                  onToggleTheme: themeNotifier.toggle,
                  isDark: themeNotifier.isDark,
                ),
                Expanded(child: widget.child),
              ],
            ),
            if (_paletteOpen)
              CommandPalette(
                onClose: _closePalette,
                onToggleTheme: themeNotifier.toggle,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TopBar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const _TopBar({
    required this.onSearchTap,
    required this.onToggleTheme,
    required this.isDark,
  });

  static const _navItems = [
    ('Overview', '/'),
    ('Inventory', '/inventory'),
    ('Filaments', '/filaments'),
    ('Sales', '/sales'),
    ('Expenses', '/expenses'),
    ('Leads', '/leads'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.blColors;
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: c.bg2,
        border: Border(bottom: BorderSide(color: c.rule, width: 1)),
      ),
      child: Row(
        children: [
          // Brand wordmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Better Lamps.',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: c.ink,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Container(width: 1, height: 24, color: c.rule),
          // Nav tabs
          Expanded(
            child: Row(
              children: _navItems.map((item) {
                final (label, path) = item;
                final isActive = path == '/'
                    ? location == '/'
                    : location.startsWith(path);
                return _NavTab(
                  label: label,
                  isActive: isActive,
                  onTap: () => context.go(path),
                );
              }).toList(),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: c.rule),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 14, color: c.muted),
                    const SizedBox(width: 6),
                    Text(
                      '⌘K',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: c.muted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Theme toggle
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: onToggleTheme,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 16,
                  color: c.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? c.coral : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
                color: widget.isActive
                    ? c.ink
                    : (_hovered ? c.ink2 : c.muted),
                letterSpacing: -0.07,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
