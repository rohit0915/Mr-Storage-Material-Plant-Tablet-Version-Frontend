import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CommonPaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final int totalEntries;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onRowsPerPageChanged;
  final List<int> rowsPerPageOptions;

  const CommonPaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.rowsPerPage = 10,
    this.totalEntries = 0,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.rowsPerPageOptions = const [5, 10, 20, 50],
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotalPages = totalPages > 0 ? totalPages : 1;
    final effectiveCurrentPage = currentPage.clamp(1, effectiveTotalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rows per page dropdown & Entries count
          Row(
            children: [
              const Text(
                'Row Per Page',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              if (onRowsPerPageChanged != null)
                PopupMenuButton<int>(
                  onSelected: onRowsPerPageChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) => rowsPerPageOptions
                      .map(
                        (opt) => PopupMenuItem<int>(
                          value: opt,
                          child: Text(
                            '$opt',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.inputBorder),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$rowsPerPage',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.inputBorder),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(
                    '$rowsPerPage',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Text(
                'Entries',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          // Pagination Page Numbers Controls
          Row(
            children: [
              // Chevron Left (Previous Page)
              InkWell(
                onTap: effectiveCurrentPage > 1
                    ? () => onPageChanged?.call(effectiveCurrentPage - 1)
                    : null,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: effectiveCurrentPage > 1
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Page Items
              ..._buildPageItems(effectiveCurrentPage, effectiveTotalPages),

              const SizedBox(width: 4),

              // Chevron Right (Next Page)
              InkWell(
                onTap: effectiveCurrentPage < effectiveTotalPages
                    ? () => onPageChanged?.call(effectiveCurrentPage + 1)
                    : null,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: effectiveCurrentPage < effectiveTotalPages
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageItems(int current, int total) {
    final pages = _generatePageNumbers(current, total);
    return pages.map((p) {
      if (p == '...') {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      final pageNum = int.tryParse(p) ?? 1;
      final isSelected = pageNum == current;

      return InkWell(
        onTap: () => onPageChanged?.call(pageNum),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            p,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<String> _generatePageNumbers(int current, int total) {
    if (total <= 6) {
      return List.generate(total, (i) => '${i + 1}');
    }

    if (current <= 4) {
      return ['1', '2', '3', '4', '...', '$total'];
    } else if (current >= total - 3) {
      return ['1', '...', '${total - 3}', '${total - 2}', '${total - 1}', '$total'];
    } else {
      return ['1', '...', '${current - 1}', '$current', '${current + 1}', '...', '$total'];
    }
  }
}
