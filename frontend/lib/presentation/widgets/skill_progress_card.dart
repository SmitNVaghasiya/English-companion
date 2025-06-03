import 'package:flutter/material.dart';
import '../../core/constants/progress_constants.dart' as progress_consts;

/// A card widget displaying a skill's progress with a progress bar and level label.
class SkillProgressCard extends StatelessWidget {
  final String skillName;
  final double progress;
  final IconData icon;
  final Color color;
  final String? description;

  const SkillProgressCard({
    super.key,
    required this.skillName,
    required this.progress,
    required this.icon,
    required this.color,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.brightness == Brightness.dark
                          ? progress_consts.AppColors.textDark.withValues(
                            alpha: 0.7,
                          )
                          : progress_consts.AppColors.textLight.withValues(
                            alpha: 0.54,
                          ),
                ),
                semanticsLabel: 'Description: $description',
              ),
            ],
            const SizedBox(height: 16),
            _buildProgressBar(theme),
            const SizedBox(height: 8),
            _buildProgressLabel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              skillName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              semanticsLabel: skillName,
            ),
          ],
        ),
        Text(
          '${progress.toInt()}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          semanticsLabel: '$progress percent',
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Semantics(
      label: 'Progress: ${progress.toInt()} percent',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress / 100,
          backgroundColor:
              theme.brightness == Brightness.dark
                  ? progress_consts.AppColors.backgroundDark
                  : progress_consts.AppColors.backgroundLight,
          color: color,
          minHeight: 8,
        ),
      ),
    );
  }

  Widget _buildProgressLabel(BuildContext context) {
    final theme = Theme.of(context);
    final level = progress_consts.ProgressLevel.fromProgress(progress);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: level.color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            level.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: level.color,
              fontWeight: FontWeight.bold,
            ),
            semanticsLabel: 'Level: ${level.label}',
          ),
        ),
      ],
    );
  }
}
