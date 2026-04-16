import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String note;

  @HiveField(6)
  late bool isExpense; // true = expense, false = income

  @HiveField(7)
  late String categoryIcon;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    this.isExpense = true,
    this.categoryIcon = '📦',
  });
}
