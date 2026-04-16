import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'expense_provider.dart';
import 'app_theme.dart';

class ExportDialog extends StatefulWidget {
  final ExpenseProvider provider;
  const ExportDialog({super.key, required this.provider});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isExporting = false;

  Future<void> _exportCSV() async {
    setState(() => _isExporting = true);
    try {
      final expenses = widget.provider.getExpensesForExport();
      final rows = [
        ['Date', 'Title', 'Category', 'Type', 'Amount', 'Note'],
        ...expenses.map((e) => [
              DateFormat('yyyy-MM-dd').format(e.date),
              e.title,
              e.category,
              e.isExpense ? 'Expense' : 'Income',
              e.amount.toStringAsFixed(2),
              e.note,
            ]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/expenses_export.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'My Expense Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);
    try {
      final expenses = widget.provider.getExpensesForExport();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'ExpenseIQ - Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Income',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text(
                        '\$${widget.provider.totalIncome.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Expenses',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text(
                        '\$${widget.provider.totalExpenses.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Balance',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text(
                        '\$${widget.provider.balance.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table.fromTextArray(
              headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
              data: expenses.map((e) => [
                    DateFormat('MMM dd').format(e.date),
                    e.title,
                    e.category,
                    e.isExpense ? 'Expense' : 'Income',
                    '\$${e.amount.toStringAsFixed(2)}',
                  ]).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
              },
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/expense_report.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'My Expense Report PDF');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Iconsax.export, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text('Export Data', style: theme.textTheme.titleLarge),
        ],
      ),
      content: _isExporting
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export all your transactions in your preferred format.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _exportButton(
                  context,
                  icon: '📊',
                  label: 'Export as CSV',
                  subtitle: 'Open in Excel or Google Sheets',
                  onTap: _exportCSV,
                ),
                const SizedBox(height: 12),
                _exportButton(
                  context,
                  icon: '📄',
                  label: 'Export as PDF',
                  subtitle: 'Formatted report with summary',
                  onTap: _exportPDF,
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _exportButton(BuildContext context,
      {required String icon,
      required String label,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
