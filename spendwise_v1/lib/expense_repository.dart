import 'package:hive/hive.dart';
import 'expense_model.dart';
import 'hive_constants.dart';

class ExpenseRepository {
  Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(HiveConstants.expenseBox);

  List<ExpenseModel> getAllExpenses() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExpenseModel> getExpensesByMonth(int month, int year) {
    return _box.values
        .where((e) => e.date.month == month && e.date.year == year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExpenseModel> getExpensesByCategory(String category) {
    return _box.values.where((e) => e.category == category).toList();
  }

  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where((e) => e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  double getTotalExpensesForMonth(int month, int year) {
    return getExpensesByMonth(month, year)
        .where((e) => e.isExpense)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getTotalIncomeForMonth(int month, int year) {
    return getExpensesByMonth(month, year)
        .where((e) => !e.isExpense)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryTotalsForMonth(int month, int year) {
    final expenses = getExpensesByMonth(month, year).where((e) => e.isExpense);
    final Map<String, double> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  /// Returns daily totals for a given month
  Map<int, double> getDailyTotalsForMonth(int month, int year) {
    final expenses = getExpensesByMonth(month, year).where((e) => e.isExpense);
    final Map<int, double> dailyTotals = {};
    for (var e in expenses) {
      dailyTotals[e.date.day] = (dailyTotals[e.date.day] ?? 0) + e.amount;
    }
    return dailyTotals;
  }
}
