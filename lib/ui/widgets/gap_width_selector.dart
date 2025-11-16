import 'package:flutter/material.dart';

/// Widget for selecting diastasis recti gap width in finger widths
class GapWidthSelector extends StatelessWidget {
  final double? selectedGap;
  final ValueChanged<double> onGapSelected;
  final String label;
  final String? hint;

  const GapWidthSelector({
    super.key,
    required this.selectedGap,
    required this.onGapSelected,
    this.label = 'Gap Width (finger widths)',
    this.hint,
  });

  static const List<double> gapOptions = [0, 1, 1.5, 2, 2.5, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: gapOptions.map((gap) {
              final isSelected = selectedGap == gap;
              return InkWell(
                onTap: () => onGapSelected(gap),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFB6C1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFB6C1)
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    gap == gap.toInt() ? gap.toInt().toString() : gap.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedGap != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected: ',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      '${selectedGap == selectedGap!.toInt() ? selectedGap!.toInt().toString() : selectedGap.toString()} finger${selectedGap! > 1 ? 's' : ''}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFFFB6C1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
