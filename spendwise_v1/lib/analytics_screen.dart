import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
// ignore: unused_import
import 'package:iconsax/iconsax.dart';
import 'expense_provider.dart';
import 'app_theme.dart';
import 'hive_constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const List<Color> _chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF03DAC6),
    Color(0xFFFF6584),
    Color(0xFFFFB100),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF00BCD4),
    Color(0xFF8BC34A),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        final categoryTotals = provider.categoryTotals;
        final dailyTotals = provider.dailyTotals;
        final entries = categoryTotals.entries.toList();
        final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Text('Spending by Category', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  _buildEmptyState(context)
                else ...[
                  SizedBox(
                    height: 280,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: PieChart(
                            PieChartData(
                              sections: entries.asMap().entries.map((e) {
                                final i = e.key;
                                final entry = e.value;
                                final percent = total > 0 ? (entry.value / total) * 100 : 0;
                                return PieChartSectionData(
                                  value: entry.value,
                                  color: _chartColors[i % _chartColors.length],
                                  title: '${percent.toStringAsFixed(0)}%',
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: entries.asMap().entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _chartColors[e.key % _chartColors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        e.value.key,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  Text('Category Breakdown', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...entries.asMap().entries.map((e) {
                    final i = e.key;
                    final entry = e.value;
                    final percent = total > 0 ? entry.value / total : 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${AppConstants.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _chartColors[i % _chartColors.length],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor:
                                  _chartColors[i % _chartColors.length].withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _chartColors[i % _chartColors.length]),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Daily Bar Chart
                  Text('Daily Spending', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (dailyTotals.isEmpty)
                    _buildEmptyState(context)
                  else
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (dailyTotals.values.isEmpty
                                  ? 100
                                  : dailyTotals.values.reduce((a, b) => a > b ? a : b)) *
                              1.2,
                          barGroups: dailyTotals.entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: AppTheme.primaryColor,
                                  width: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                  '${v.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('📊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'No data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Add some transactions to see your analytics',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
