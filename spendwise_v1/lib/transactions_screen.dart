import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'expense_provider.dart';
import 'app_theme.dart';
import 'expense_model.dart';
import 'add_expense_screen.dart';
import 'export_dialog.dart';
import 'hive_constants.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Expense', 'Income', 'Food & Dining', 'Transportation',
    'Shopping', 'Entertainment', 'Health & Fitness', 'Bills & Utilities',
    'Education', 'Travel', 'Savings', 'Investment',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> expenses) {
    List<ExpenseModel> filtered = expenses;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_selectedFilter == 'Expense') {
      filtered = filtered.where((e) => e.isExpense).toList();
    } else if (_selectedFilter == 'Income') {
      filtered = filtered.where((e) => !e.isExpense).toList();
    } else if (_selectedFilter != 'All') {
      filtered = filtered.where((e) => e.category == _selectedFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final allExpenses = provider.expenses;
        final filtered = _applyFilters(allExpenses);

        // Group by date
        final Map<String, List<ExpenseModel>> grouped = {};
        for (var e in filtered) {
          final key = DateFormat('MMM dd, yyyy').format(e.date);
          grouped.putIfAbsent(key, () => []).add(e);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transactions'),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.export),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ExportDialog(provider: provider),
                ),
                tooltip: 'Export',
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Iconsax.close_circle, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    final isSelected = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} transactions',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Total: ${AppConstants.currencySymbol}${filtered.where((e) => e.isExpense).fold(0.0, (s, e) => s + e.amount).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: grouped.keys.length,
                        itemBuilder: (_, i) {
                          final date = grouped.keys.elementAt(i);
                          final items = grouped[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  date,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              ...items.map((expense) => Slidable(
                                    key: Key(expense.id),
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (_) =>
                                              provider.deleteExpense(expense.id),
                                          backgroundColor: AppTheme.errorColor,
                                          foregroundColor: Colors.white,
                                          icon: Iconsax.trash,
                                          label: 'Delete',
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ],
                                    ),
                                    child: _buildTransactionTile(context, expense, provider),
                                  )),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Iconsax.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(
      BuildContext context, ExpenseModel expense, ExpenseProvider provider) {
    final theme = Theme.of(context);
    final color = expense.isExpense ? AppTheme.errorColor : AppTheme.successColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(expense.categoryIcon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.category,
                  style: theme.textTheme.bodyMedium,
                ),
                if (expense.note.isNotEmpty)
                  Text(
                    expense.note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.isExpense ? '-' : '+'}${AppConstants.currencySymbol}${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(expense.date),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('No transactions found', style: Theme.of(context).textTheme.titleLarge),
          Text('Try adjusting your search or filters.',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
