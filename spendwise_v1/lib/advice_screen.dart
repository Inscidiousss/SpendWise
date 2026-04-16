import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:iconsax/iconsax.dart';
import 'expense_provider.dart';
import '/app_theme.dart';
import 'hive_constants.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        final rate = provider.savingsRate;
        final balance = provider.balance;
        final totalIncome = provider.totalIncome;
        final totalExpenses = provider.totalExpenses;

        return Scaffold(
          appBar: AppBar(title: const Text('Smart Advice 🧠')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Advice Banner
                _buildAdviceBanner(context, provider),
                const SizedBox(height: 20),

                // Financial Health Score
                Text('Financial Health Score', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildHealthScore(context, rate),
                const SizedBox(height: 20),

                // Savings Tips
                Text('Savings Strategies', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ..._getSavingsTips(rate, totalIncome, totalExpenses, balance)
                    .map((tip) => _buildTipCard(context, tip)),
                const SizedBox(height: 20),

                // Investment Advice
                Text('Investment Insights', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ..._getInvestmentTips(balance, rate)
                    .map((tip) => _buildTipCard(context, tip)),
                const SizedBox(height: 20),

                // Spending Patterns
                Text('Spending Patterns', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildSpendingPatterns(context, provider),
                const SizedBox(height: 20),

                // 50/30/20 Rule Breakdown
                Text('50/30/20 Rule', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'A simple framework for healthy budgeting',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _buildRuleBreakdown(context, totalIncome),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdviceBanner(BuildContext context, ExpenseProvider provider) {
    final advice = provider.getSavingsAdvice();
    final rate = provider.savingsRate;
    final color = rate >= 0.3
        ? AppTheme.successColor
        : rate >= 0.1
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Financial Advisor',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(advice, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore(BuildContext context, double rate) {
    final score = (rate * 100).clamp(0.0, 100.0);
    final color = score >= 30
        ? AppTheme.successColor
        : score >= 10
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    final label = score >= 30
        ? 'Excellent 🌟'
        : score >= 20
            ? 'Good ✅'
            : score >= 10
                ? 'Fair 📊'
                : 'Needs Attention ⚠️';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score', style: Theme.of(context).textTheme.bodyLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, Map<String, String> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip['icon']!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title']!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['body']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingPatterns(BuildContext context, ExpenseProvider provider) {
    final topCat = provider.getTopSpendingCategory();
    final topAmt = provider.getTopCategoryAmount();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _patternRow(context, 'Top Spending', topCat, AppTheme.errorColor),
          const Divider(height: 20),
          _patternRow(context, 'Top Amount',
              '${AppConstants.currencySymbol}${topAmt.toStringAsFixed(2)}', AppTheme.warningColor),
          const Divider(height: 20),
          _patternRow(context, 'Avg Daily',
              '${AppConstants.currencySymbol}${(provider.totalExpenses / 30).toStringAsFixed(2)}', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _patternRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleBreakdown(BuildContext context, double income) {
    final needs = income * 0.5;
    final wants = income * 0.3;
    final savings = income * 0.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ruleRow(context, '50% Needs', needs, AppTheme.primaryColor,
              'Rent, food, transport, utilities'),
          const SizedBox(height: 12),
          _ruleRow(context, '30% Wants', wants, AppTheme.accentColor,
              'Entertainment, dining out, hobbies'),
          const SizedBox(height: 12),
          _ruleRow(context, '20% Savings', savings, AppTheme.successColor,
              'Emergency fund, investments, debt'),
        ],
      ),
    );
  }

  Widget _ruleRow(BuildContext context, String label, double amount,
      Color color, String desc) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(desc, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getSavingsTips(
      double rate, double income, double expenses, double balance) {
    final tips = <Map<String, String>>[];

    if (rate < 0.1) {
      tips.add({
        'icon': '🎯',
        'title': 'Start Small',
        'body': 'Aim to save just 5% of your income first. Automate it so you never forget.',
      });
      tips.add({
        'icon': '✂️',
        'title': 'Cut Subscriptions',
        'body': 'Review your monthly subscriptions. Cancelling just 2-3 unused ones can save ${AppConstants.currencySymbol}300-500/month.',
      });
    }

    if (rate >= 0.1) {
      tips.add({
        'icon': '🏦',
        'title': 'Emergency Fund',
        'body': 'Build 3-6 months of expenses as an emergency fund before investing. Target: ${AppConstants.currencySymbol}${(expenses * 3).toStringAsFixed(0)}.',
      });
    }

    tips.add({
      'icon': '🔄',
      'title': 'Pay Yourself First',
      'body': 'Transfer savings to a separate account immediately on payday. Spend what remains.',
    });

    tips.add({
      'icon': '🛒',
      'title': 'Track Every Dollar',
      'body': 'People who track expenses save 20% more on average. You\'re already doing this — great!',
    });

    return tips;
  }

  List<Map<String, String>> _getInvestmentTips(double balance, double rate) {
    final tips = <Map<String, String>>[];

    if (balance > 500) {
      tips.add({
        'icon': '📈',
        'title': 'Index Funds',
        'body': 'Low-cost index funds (S&P 500) have historically returned ~10% annually. Start with ${AppConstants.currencySymbol}${(balance * 0.5).toStringAsFixed(0)}.',
      });
    }

    tips.add({
      'icon': '🏛️',
      'title': 'Retirement Account',
      'body': 'Max out tax-advantaged accounts (401k, IRA) first — tax savings compound over decades.',
    });

    tips.add({
      'icon': '💹',
      'title': 'Dollar-Cost Averaging',
      'body': 'Invest a fixed amount monthly regardless of market conditions to reduce timing risk.',
    });

    tips.add({
      'icon': '🌍',
      'title': 'Diversification',
      'body': 'Spread investments across stocks, bonds, and real estate to reduce risk.',
    });

    return tips;
  }
}
