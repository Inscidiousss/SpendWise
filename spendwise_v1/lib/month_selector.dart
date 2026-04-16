import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';

class MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final void Function(int month, int year) onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime(selectedYear, selectedMonth);
    final label = DateFormat('MMMM yyyy').format(date);
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth == now.month && selectedYear == now.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final prev = DateTime(selectedYear, selectedMonth - 1);
            onChanged(prev.month, prev.year);
          },
          icon: const Icon(Iconsax.arrow_left_2),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (picked != null) {
              onChanged(picked.month, picked.year);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
                if (isCurrentMonth) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NOW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: isCurrentMonth
              ? null
              : () {
                  final next = DateTime(selectedYear, selectedMonth + 1);
                  if (next.isBefore(DateTime(now.year, now.month + 1))) {
                    onChanged(next.month, next.year);
                  }
                },
          icon: const Icon(Iconsax.arrow_right_3),
          style: IconButton.styleFrom(
            backgroundColor:
                isCurrentMonth ? Colors.grey.withOpacity(0.1) : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
