import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'expense_model.dart';
import 'expense_repository.dart';
import 'hive_constants.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();
  final _uuid = const Uuid();

  List<ExpenseModel> _expenses = [];
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _filterCategory = 'All';

  List<ExpenseModel> get expenses => _expenses;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  String get filterCategory => _filterCategory;

  List<ExpenseModel> get filteredExpenses {
    if (_filterCategory == 'All') return _expenses;
    return _expenses.where((e) => e.category == _filterCategory).toList();
  }

  double get totalExpenses => _expenses
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalIncome => _expenses
      .where((e) => !e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpenses;

  double get savingsRate {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome).clamp(0.0, 1.0);
  }

  Map<String, double> get categoryTotals =>
      _repo.getCategoryTotalsForMonth(_selectedMonth, _selectedYear);

  Map<int, double> get dailyTotals =>
      _repo.getDailyTotalsForMonth(_selectedMonth, _selectedYear);

  List<ExpenseModel> get recentExpenses =>
      _repo.getAllExpenses().take(10).toList();

  ExpenseProvider() {
    loadExpenses();
  }

  void loadExpenses() {
    _expenses = _repo.getExpensesByMonth(_selectedMonth, _selectedYear);
    notifyListeners();
  }

  void setMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    loadExpenses();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String note = '',
    bool isExpense = true,
    String categoryIcon = '📦',
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
      isExpense: isExpense,
      categoryIcon: categoryIcon,
    );
    await _repo.addExpense(expense);
    loadExpenses();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _repo.updateExpense(expense);
    loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _repo.deleteExpense(id);
    loadExpenses();
  }

  /// AI-style savings & investment advice
  String getSavingsAdvice() {
    final rate = savingsRate * 100;
    final savings = balance;

    if (totalIncome == 0) {
      return "💡 Start by logging your income to get personalized savings advice!";
    }

    if (rate >= 30) {
      return "🌟 Excellent! You're saving ${rate.toStringAsFixed(1)}% of your income. "
          "Consider investing your surplus in index funds or a high-yield savings account. "
          "You could put ${AppConstants.currencySymbol}${(savings * 0.5).toStringAsFixed(2)} into a diversified portfolio.";
    } else if (rate >= 20) {
      return "✅ Great job! You're saving ${rate.toStringAsFixed(1)}%. "
          "Try to reach 30% by cutting non-essential spending. "
          "Consider allocating some savings to ETFs or bonds for long-term growth.";
    } else if (rate >= 10) {
      return "📊 You're saving ${rate.toStringAsFixed(1)}% — a fair start! "
          "Aim to reduce your top spending category and grow savings to 20%. "
          "Even small investments now benefit from compound interest over time.";
    } else if (rate > 0) {
      return "⚠️ You're saving only ${rate.toStringAsFixed(1)}%. "
          "Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings. "
          "Review your biggest expenses this month and find areas to cut back.";
    } else {
      return "🚨 You're spending more than you earn! Immediate action needed. "
          "Review all non-essential expenses and consider additional income sources. "
          "Set a strict budget for next month.";
    }
  }

  String getTopSpendingCategory() {
    if (categoryTotals.isEmpty) return 'None';
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double getTopCategoryAmount() {
    if (categoryTotals.isEmpty) return 0;
    return categoryTotals.values.reduce((a, b) => a > b ? a : b);
  }

  List<ExpenseModel> getExpensesForExport() {
    return _repo.getAllExpenses();
  }
}
