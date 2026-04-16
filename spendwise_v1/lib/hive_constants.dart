class HiveConstants {
  static const String expenseBox = 'expenses';
  static const String budgetBox = 'budgets';
  static const String categoryBox = 'categories';
  static const String settingsBox = 'settings';
}

class AppConstants {
  static const String appName = 'ExpenseIQ';
  static const String currencySymbol = 'NRs ';

  static const List<String> defaultCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Health & Fitness',
    'Bills & Utilities',
    'Education',
    'Travel',
    'Savings',
    'Investment',
    'Others',
  ];

  static const List<String> categoryIcons = [
    '🍔', '🚗', '🛍️', '🎬', '💪', '💡', '📚', '✈️', '🏦', '📈', '📦',
  ];

  // Savings advice thresholds
  static const double excellentSavingsRate = 0.30; // 30%+ savings
  static const double goodSavingsRate = 0.20;       // 20-30%
  static const double fairSavingsRate = 0.10;       // 10-20%

  // Investment advice minimum
  static const double investmentThreshold = 500.0;
}
