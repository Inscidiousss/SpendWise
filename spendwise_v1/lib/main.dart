import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'hive_constants.dart';
import 'expense_model.dart';
import 'budget_model.dart';
import 'category_model.dart';
import 'expense_provider.dart';
import 'budget_provider.dart';
import 'theme_provider.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Open Hive Boxes
  await Hive.openBox<ExpenseModel>(HiveConstants.expenseBox);
  await Hive.openBox<BudgetModel>(HiveConstants.budgetBox);
  await Hive.openBox<CategoryModel>(HiveConstants.categoryBox);
  await Hive.openBox(HiveConstants.settingsBox);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ExpenseIQ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
