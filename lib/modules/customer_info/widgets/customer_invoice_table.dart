import 'package:flutter/material.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_icons.dart';
import '../model/customer_info_model.dart';

class CustomerInvoiceTable extends StatelessWidget {
  final List<CustomerInvoiceModel> invoices;

  const CustomerInvoiceTable({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            // Header Row with Title and Export Action Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Invoice List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      // PDF Icon Button
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.badgeRedBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          AppIcons.pdf,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 16,
                                color: AppColors.badgeRedText,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // XLS Icon Button
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          AppIcons.xls,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.table_chart,
                                size: 16,
                                color: AppColors.badgeGreenText,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Print Icon Button
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: const Icon(
                          Icons.print_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(color: AppColors.inputBackground),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Invoice Number',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Amount Due',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Table Rows
            ...List.generate(invoices.length, (index) {
              final row = invoices[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pendingApprovalCard,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.dueDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.amount,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.paid,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.amountDue,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusPill(row.status, row.isPaid),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < invoices.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String text, bool isPaid) {
    final bg = isPaid ? AppColors.badgeGreenBg : AppColors.badgeRedBg;
    final fg = isPaid ? AppColors.badgeGreenText : AppColors.badgeRedText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
