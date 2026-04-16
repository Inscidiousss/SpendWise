import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'expense_provider.dart';
import 'theme_provider.dart';
import 'app_theme.dart';
import 'add_expense_screen.dart';
import 'expense_card.dart';
import 'summary_card.dart';
import 'month_selector.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Good ${_getGreeting()}! 👋',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'ExpenseIQ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Iconsax.sun_1
                                            : Iconsax.moon,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          context.read<ThemeProvider>().toggleTheme(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Balance',
                              style: TextStyle(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '\$${provider.balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Iconsax.notification, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Selector
                      MonthSelector(
                        selectedMonth: provider.selectedMonth,
                        selectedYear: provider.selectedYear,
                        onChanged: (m, y) => provider.setMonth(m, y),
                      ),
                      const SizedBox(height: 16),

                      // Income / Expense summary cards
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Income',
                              amount: provider.totalIncome,
                              icon: Iconsax.arrow_down,
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              title: 'Expenses',
                              amount: provider.totalExpenses,
                              icon: Iconsax.arrow_up,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Savings Rate
                      _buildSavingsRateCard(provider, context),
                      const SizedBox(height: 20),

                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (provider.filteredExpenses.isEmpty)
                        _buildEmptyState(context)
                      else
                        ...provider.filteredExpenses
                            .take(5)
                            .map((expense) => ExpenseCard(expense: expense)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Iconsax.add, color: Colors.white),
            label: const Text(
              'Add',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavingsRateCard(ExpenseProvider provider, BuildContext context) {
    final rate = provider.savingsRate;
    final color = rate >= 0.3
        ? AppTheme.successColor
        : rate >= 0.1
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings Rate',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(rate * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate >= 0.3
                ? '🌟 Excellent saving habit!'
                : rate >= 0.1
                    ? '✅ Keep building your savings.'
                    : '⚠️ Try to save more this month.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('💸', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + Add to record your first transaction',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
