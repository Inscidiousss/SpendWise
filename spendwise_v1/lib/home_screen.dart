import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'advice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    AdviceScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Iconsax.receipt), label: 'Transactions'),
    BottomNavigationBarItem(icon: Icon(Iconsax.chart), label: 'Analytics'),
    BottomNavigationBarItem(icon: Icon(Iconsax.wallet), label: 'Budget'),
    BottomNavigationBarItem(icon: Icon(Iconsax.magic_star), label: 'Advice'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                isDark ? const Color(0xFF1E1E2E) : Colors.white,
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
