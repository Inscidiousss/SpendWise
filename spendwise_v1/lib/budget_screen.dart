import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'expense_provider.dart';
import 'budget_provider.dart';
import 'app_theme.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ExpenseProvider, BudgetProvider>(
      builder: (context, expenseProvider, budgetProvider, _) {
        final month = expenseProvider.selectedMonth;
        final year = expenseProvider.selectedYear;
        final categoryTotals = expenseProvider.categoryTotals;
        final budgets = budgetProvider.getBudgetsForMonth(month, year);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Budget'),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.add_circle),
                onPressed: () => _showAddBudgetDialog(context, expenseProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Budget Overview Card
                _buildOverviewCard(context, budgets, categoryTotals),
                const SizedBox(height: 20),

                Text('Category Budgets', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),

                if (budgets.isEmpty)
                  _buildEmptyState(context, expenseProvider)
                else
                  ...budgets.map((budget) {
                    final spent = categoryTotals[budget.category] ?? 0.0;
                    final progress = budgetProvider.getBudgetProgress(
                        budget.category, spent, month, year);
                    final isOver = budgetProvider.isOverBudget(
                        budget.category, spent, month, year);

                    return _buildBudgetCard(
                        context, budget, spent, progress, isOver, budgetProvider);
                  }),

                const SizedBox(height: 20),

                // Unbudgeted categories
                if (categoryTotals.isNotEmpty) ...[
                  Text('Untracked Spending', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'These categories have spending but no budget set.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ...categoryTotals.entries
                      .where((e) =>
                          !budgets.any((b) => b.category == e.key))
                      .map((e) => _buildUntrackedCard(context, e.key, e.value, expenseProvider)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(BuildContext context,
      List budgets, Map<String, double> categoryTotals) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final totalLimit = budgets.fold<double>(0, (sum, b) => sum + b.limit);
    final totalSpent = budgets.fold<double>(
        0, (sum, b) => sum + (categoryTotals[b.category] ?? 0));
    final remaining = totalLimit - totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Budget Overview',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _overviewStat('Total Budget', '\$${totalLimit.toStringAsFixed(0)}'),
              _overviewStat('Spent', '\$${totalSpent.toStringAsFixed(0)}'),
              _overviewStat(
                'Remaining',
                '\$${remaining.toStringAsFixed(0)}',
                color: remaining < 0 ? const Color(0xFFFF6584) : const Color(0xFF03DAC6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                totalSpent > totalLimit ? const Color(0xFFFF6584) : const Color(0xFF03DAC6),
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, budget, double spent,
      double progress, bool isOver, BudgetProvider budgetProvider) {
    final theme = Theme.of(context);
    final color = isOver
        ? AppTheme.errorColor
        : progress > 0.8
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOver ? AppTheme.errorColor.withOpacity(0.3) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    budget.category == 'Food & Dining' ? '🍔'
                        : budget.category == 'Transportation' ? '🚗'
                        : budget.category == 'Shopping' ? '🛍️'
                        : budget.category == 'Entertainment' ? '🎬'
                        : budget.category == 'Health & Fitness' ? '💪'
                        : budget.category == 'Bills & Utilities' ? '💡'
                        : budget.category == 'Education' ? '📚'
                        : budget.category == 'Travel' ? '✈️'
                        : budget.category == 'Savings' ? '🏦'
                        : budget.category == 'Investment' ? '📈'
                        : '📦',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${spent.toStringAsFixed(2)} / \$${budget.limit.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (isOver)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⚠️ Over',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 18, color: Colors.grey),
                    onPressed: () => budgetProvider.deleteBudget(budget.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% used',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUntrackedCard(BuildContext context, String category,
      double amount, ExpenseProvider expenseProvider) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: theme.textTheme.bodyLarge),
          Row(
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    _showAddBudgetDialog(context, expenseProvider, category: category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Set Budget',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExpenseProvider provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('🎯', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('No budgets set', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Tap + to set category budgets',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, ExpenseProvider expenseProvider,
      {String? category}) {
    final amountController = TextEditingController();
    String selectedCategory = category ?? 'Food & Dining';
    final categories = [
      'Food & Dining', 'Transportation', 'Shopping', 'Entertainment',
      'Health & Fitness', 'Bills & Utilities', 'Education', 'Travel',
      'Savings', 'Investment', 'Others',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Budget', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Budget Limit',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      await context.read<BudgetProvider>().setBudget(
                            category: selectedCategory,
                            limit: amount,
                            month: expenseProvider.selectedMonth,
                            year: expenseProvider.selectedYear,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Budget'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
