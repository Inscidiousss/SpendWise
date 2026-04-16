import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'budget_model.dart';
import 'hive_constants.dart';

class BudgetProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  Box<BudgetModel> get _box => Hive.box<BudgetModel>(HiveConstants.budgetBox);

  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  BudgetProvider() {
    loadBudgets();
  }

  void loadBudgets() {
    _budgets = _box.values.toList();
    notifyListeners();
  }

  BudgetModel? getBudgetForCategory(String category, int month, int year) {
    try {
      return _budgets.firstWhere(
        (b) => b.category == category && b.month == month && b.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    final existing = getBudgetForCategory(category, month, year);
    if (existing != null) {
      existing.limit = limit;
      await existing.save();
    } else {
      final budget = BudgetModel(
        id: _uuid.v4(),
        category: category,
        limit: limit,
        month: month,
        year: year,
      );
      await _box.put(budget.id, budget);
    }
    loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _box.delete(id);
    loadBudgets();
  }

  List<BudgetModel> getBudgetsForMonth(int month, int year) {
    return _budgets.where((b) => b.month == month && b.year == year).toList();
  }

  bool isOverBudget(String category, double spent, int month, int year) {
    final budget = getBudgetForCategory(category, month, year);
    if (budget == null) return false;
    return spent > budget.limit;
  }

  double getBudgetProgress(String category, double spent, int month, int year) {
    final budget = getBudgetForCategory(category, month, year);
    if (budget == null || budget.limit == 0) return 0;
    return (spent / budget.limit).clamp(0.0, 1.0);
  }
}
