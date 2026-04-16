import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 1)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late double limit;

  @HiveField(3)
  late int month; // 1-12

  @HiveField(4)
  late int year;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });
}
