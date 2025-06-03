import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/string_utils.dart';

/// A card widget displaying a radar chart of skill scores.
class ProgressChart extends StatelessWidget {
  final Map<String, double> skillScores;

  const ProgressChart({super.key, required this.skillScores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (skillScores.isEmpty) {
      return Semantics(
        label: 'No skill scores available',
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No skill data available'),
          ),
        ),
      );
    }

    if (skillScores.length < 3) {
      return Semantics(
        label: 'Insufficient skill scores for radar chart',
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('At least 3 skills are required for the chart'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Skills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              semanticsLabel: 'Your Skills',
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _RadarChart(
                skillScores: skillScores,
                backgroundColor:
                    theme.brightness == Brightness.dark
                        ? AppColors.primaryColor.withValues(alpha: 0.5)
                        : AppColors.primaryColor.withValues(alpha: 0.5),
                gridColor:
                    theme.brightness == Brightness.dark
                        ? AppColors.primaryColor.withValues(alpha: 0.5)
                        : AppColors.primaryColor.withValues(alpha: 0.5),
                skillColors:
                    skillScores.keys
                        .map((key) => _getColorForSkill(key))
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  skillScores.entries.map((entry) {
                    final color = _getColorForSkill(entry.key);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${StringUtils.formatSkillName(entry.key)}: ${entry.value.toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.brightness == Brightness.dark
                                    ? AppColors.primaryColor.withValues(
                                      alpha: 0.7,
                                    )
                                    : AppColors.primaryColor.withValues(
                                      alpha: 0.87,
                                    ),
                          ),
                          semanticsLabel:
                              '${StringUtils.formatSkillName(entry.key)}: ${entry.value.toInt()} percent',
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSkill(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'pronunciation':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      case 'vocabulary':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      case 'grammar':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      case 'fluency':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      case 'comprehension':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      case 'confidence':
        return AppColors.primaryColor.withValues(alpha: 0.7);
      default:
        final hash = skillName.hashCode;
        return Color((hash & 0xFFFFFF) | 0xFF000000);
    }
  }
}

class _RadarChart extends StatelessWidget {
  final Map<String, double> skillScores;
  final Color backgroundColor;
  final Color gridColor;
  final List<Color> skillColors;

  const _RadarChart({
    required this.skillScores,
    required this.backgroundColor,
    required this.gridColor,
    required this.skillColors,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _RadarChartPainter(
        skillScores: skillScores,
        backgroundColor: backgroundColor,
        gridColor: gridColor,
        skillColors: skillColors,
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> skillScores;
  final Color backgroundColor;
  final Color gridColor;
  final List<Color> skillColors;

  _RadarChartPainter({
    required this.skillScores,
    required this.backgroundColor,
    required this.gridColor,
    required this.skillColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 20;

    // Draw background
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    // Draw grid lines
    final gridPaint =
        Paint()
          ..color = gridColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, gridPaint);
    }

    final skills = skillScores.keys.toList();
    final skillCount = skills.length;
    final angleStep = 2 * pi / skillCount;

    // Draw axis lines and labels
    for (var i = 0; i < skillCount; i++) {
      final angle = -pi / 2 + i * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.drawLine(center, Offset(x, y), gridPaint);

      final labelRadius = radius + 15;
      final labelX = center.dx + labelRadius * cos(angle);
      final labelY = center.dy + labelRadius * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: StringUtils.formatSkillName(skills[i]),
          style: TextStyle(
            color: skillColors[i],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    // Draw skill data
    final dataPoints = <Offset>[];
    for (var i = 0; i < skillCount; i++) {
      final score = (skillScores[skills[i]] ?? 0) / 100;
      final angle = -pi / 2 + i * angleStep;
      dataPoints.add(
        Offset(
          center.dx + radius * score * cos(angle),
          center.dy + radius * score * sin(angle),
        ),
      );
    }

    final skillPath = Path()..moveTo(dataPoints[0].dx, dataPoints[0].dy);
    for (var i = 1; i < dataPoints.length; i++) {
      skillPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
    }
    skillPath.close();

    canvas.drawPath(
      skillPath,
      Paint()
        ..color = skillColors[0].withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      skillPath,
      Paint()
        ..color = skillColors[0]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < dataPoints.length; i++) {
      canvas.drawCircle(dataPoints[i], 4, Paint()..color = skillColors[i]);
      canvas.drawCircle(
        dataPoints[i],
        2,
        Paint()..color = AppColors.primaryColor.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return skillScores != oldDelegate.skillScores ||
        backgroundColor != oldDelegate.backgroundColor ||
        gridColor != oldDelegate.gridColor ||
        skillColors != oldDelegate.skillColors;
  }
}
