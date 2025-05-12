import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResourceUsageChart extends StatelessWidget {
  final Map<String, double> resourceUsage;
  final String title;

  const ResourceUsageChart({
    super.key,
    required this.resourceUsage,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _getSections(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _getSections() {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
    ];

    int i = 0;
    resourceUsage.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value,
          title: '${value.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return sections;
  }

  Widget _buildLegend() {
    final List<Color> colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: resourceUsage.entries.map((entry) {
        final index = resourceUsage.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
