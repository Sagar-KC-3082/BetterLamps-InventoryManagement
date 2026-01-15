import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/filaments_screen.dart';
import 'screens/sales_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final databaseService = DatabaseService();
  await databaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: databaseService),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Better Lamps',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Inventory',
    ),
    _NavItem(
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
      label: 'Filaments',
    ),
    _NavItem(
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      label: 'Sales',
    ),
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const InventoryScreen();
      case 2:
        return const FilamentsScreen();
      case 3:
        return const SalesScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Row(
        children: [
          // Minimal Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                right: BorderSide(color: context.borderColor, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Better Lamps',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'MENU',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary.withOpacity(0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      ...List.generate(_navItems.length, (index) {
                        final item = _navItems[index];
                        final isSelected = _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.04))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? item.activeIcon : item.icon,
                                      color: isSelected
                                          ? context.textPrimary
                                          : context.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? context.textPrimary
                                            : context.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Spacer(),
                // Theme Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                themeService.setThemeMode(ThemeMode.light),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isDark
                                    ? (isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: !isDark
                                    ? context.subtleShadow
                                    : null,
                              ),
                              child: Icon(
                                Icons.light_mode_outlined,
                                size: 16,
                                color: !isDark
                                    ? context.textPrimary
                                    : context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                themeService.setThemeMode(ThemeMode.dark),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.dark_mode_outlined,
                                size: 16,
                                color: isDark
                                    ? context.textPrimary
                                    : context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _buildScreen(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
