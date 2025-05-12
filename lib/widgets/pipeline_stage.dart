import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PipelineStageStatus {
  notStarted,
  inProgress,
  success,
  failed,
  skipped,
}

class PipelineStage extends StatelessWidget {
  final String name;
  final PipelineStageStatus status;
  final bool isLast;

  const PipelineStage({
    super.key,
    required this.name,
    required this.status,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStageCircle(),
        if (!isLast) _buildConnectingLine(),
      ],
    );
  }

  Widget _buildStageCircle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: Center(
            child: _getIcon(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getBorderColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingLine() {
    return Container(
      width: 40,
      height: 2,
      color: _getLineColor(),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case PipelineStageStatus.notStarted:
        return Colors.transparent;
      case PipelineStageStatus.inProgress:
        return AppTheme.buildingColor.withOpacity(0.2);
      case PipelineStageStatus.success:
        return AppTheme.successColor.withOpacity(0.2);
      case PipelineStageStatus.failed:
        return AppTheme.errorColor.withOpacity(0.2);
      case PipelineStageStatus.skipped:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case PipelineStageStatus.notStarted:
        return Colors.grey;
      case PipelineStageStatus.inProgress:
        return AppTheme.buildingColor;
      case PipelineStageStatus.success:
        return AppTheme.successColor;
      case PipelineStageStatus.failed:
        return AppTheme.errorColor;
      case PipelineStageStatus.skipped:
        return Colors.grey;
    }
  }

  Color _getLineColor() {
    switch (status) {
      case PipelineStageStatus.notStarted:
        return Colors.grey.withOpacity(0.5);
      case PipelineStageStatus.inProgress:
        return AppTheme.buildingColor;
      case PipelineStageStatus.success:
        return AppTheme.successColor;
      case PipelineStageStatus.failed:
        return AppTheme.errorColor;
      case PipelineStageStatus.skipped:
        return Colors.grey.withOpacity(0.5);
    }
  }

  Widget _getIcon() {
    switch (status) {
      case PipelineStageStatus.notStarted:
        return const Icon(Icons.circle_outlined, color: Colors.grey, size: 20);
      case PipelineStageStatus.inProgress:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buildingColor),
          ),
        );
      case PipelineStageStatus.success:
        return const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20);
      case PipelineStageStatus.failed:
        return const Icon(Icons.error, color: AppTheme.errorColor, size: 20);
      case PipelineStageStatus.skipped:
        return const Icon(Icons.skip_next, color: Colors.grey, size: 20);
    }
  }
}
