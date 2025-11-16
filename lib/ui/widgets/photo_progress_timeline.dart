import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../themes/colors.dart';

/// Photo progress timeline widget for displaying before/after photos
class PhotoProgressTimeline extends StatelessWidget {
  final List<Progress> photoRecords;
  final VoidCallback onAddPhoto;

  const PhotoProgressTimeline({
    super.key,
    required this.photoRecords,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (photoRecords.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    // Sort by date (oldest first)
    final sortedPhotos = photoRecords.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_a_photo),
              tooltip: 'Add Photo',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Photos stored only on your device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: sortedPhotos.length,
          itemBuilder: (context, index) {
            final photo = sortedPhotos[index];
            return _buildPhotoCard(context, theme, photo, index);
          },
        ),
        const SizedBox(height: 16),
        // Side-by-side comparison button
        if (sortedPhotos.length >= 2)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showComparisonDialog(context, sortedPhotos);
              },
              icon: const Icon(Icons.compare),
              label: const Text('Compare Photos'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No photos yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your progress with photos',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add First Photo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    ThemeData theme,
    Progress photo,
    int index,
  ) {
    final photoPath = photo.value?['photoPath'] as String?;
    final milestone = _getMilestone(photo.weekNumber);

    return GestureDetector(
      onTap: () {
        _showPhotoDialog(context, photo);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: photoPath != null && File(photoPath).existsSync()
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (milestone != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        milestone,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Week ${photo.weekNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(photo.recordedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getMilestone(int weekNumber) {
    if (weekNumber == 1) return 'START';
    if (weekNumber == 4) return '4-WEEK';
    if (weekNumber == 8) return '8-WEEK';
    if (weekNumber == 12) return '12-WEEK';
    return null;
  }

  void _showPhotoDialog(BuildContext context, Progress photo) {
    final photoPath = photo.value?['photoPath'] as String?;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Week ${photo.weekNumber}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (photoPath != null && File(photoPath).existsSync())
              Image.file(File(photoPath))
            else
              const Padding(
                padding: EdgeInsets.all(48.0),
                child: Text('Photo not available'),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                DateFormat('MMMM d, yyyy').format(photo.recordedAt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComparisonDialog(BuildContext context, List<Progress> photos) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: _ComparisonView(photos: photos),
      ),
    );
  }
}

class _ComparisonView extends StatefulWidget {
  final List<Progress> photos;

  const _ComparisonView({required this.photos});

  @override
  State<_ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<_ComparisonView> {
  late int _beforeIndex;
  late int _afterIndex;

  @override
  void initState() {
    super.initState();
    _beforeIndex = 0;
    _afterIndex = widget.photos.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final beforePhoto = widget.photos[_beforeIndex];
    final afterPhoto = widget.photos[_afterIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: const Text('Compare Progress'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Before',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildComparisonPhoto(beforePhoto),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _beforeIndex,
                      isExpanded: true,
                      items: widget.photos.asMap().entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text('Week ${entry.value.weekNumber}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && value != _afterIndex) {
                          setState(() => _beforeIndex = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'After',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildComparisonPhoto(afterPhoto),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _afterIndex,
                      isExpanded: true,
                      items: widget.photos.asMap().entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text('Week ${entry.value.weekNumber}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && value != _beforeIndex) {
                          setState(() => _afterIndex = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonPhoto(Progress photo) {
    final theme = Theme.of(context);
    final photoPath = photo.value?['photoPath'] as String?;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath != null && File(photoPath).existsSync()
          ? Image.file(
              File(photoPath),
              fit: BoxFit.cover,
            )
          : const Center(
              child: Icon(Icons.image_not_supported_outlined),
            ),
    );
  }
}
