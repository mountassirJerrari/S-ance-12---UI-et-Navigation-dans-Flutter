import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (status is RepositoryStatus) {
      final repoStatus = status as RepositoryStatus;
      text = repoStatus.name;
      color = _getRepositoryStatusColor(repoStatus);
    } else if (status is BuildStatus) {
      final buildStatus = status as BuildStatus;
      text = buildStatus.name;
      color = _getBuildStatusColor(buildStatus);
    } else if (status is DeploymentStatus) {
      final deployStatus = status as DeploymentStatus;
      text = deployStatus.name;
      color = _getDeploymentStatusColor(deployStatus);
    } else if (status is ServiceStatus) {
      final serviceStatus = status as ServiceStatus;
      text = serviceStatus.name;
      color = _getServiceStatusColor(serviceStatus);
    } else if (status is HealthCheckStatus) {
      final healthStatus = status as HealthCheckStatus;
      text = healthStatus.name;
      color = _getHealthCheckStatusColor(healthStatus);
    } else if (status is ActivityStatus) {
      final activityStatus = status as ActivityStatus;
      text = activityStatus.name;
      color = _getActivityStatusColor(activityStatus);
    } else {
      text = status.toString();
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Color _getRepositoryStatusColor(RepositoryStatus status) {
    switch (status) {
      case RepositoryStatus.idle:
        return Colors.grey;
      case RepositoryStatus.building:
        return AppTheme.buildingColor;
      case RepositoryStatus.testing:
        return AppTheme.testingColor;
      case RepositoryStatus.deploying:
        return AppTheme.deployingColor;
      case RepositoryStatus.deployed:
        return AppTheme.successColor;
      case RepositoryStatus.failed:
        return AppTheme.errorColor;
    }
  }

  Color _getBuildStatusColor(BuildStatus status) {
    switch (status) {
      case BuildStatus.inProgress:
        return AppTheme.buildingColor;
      case BuildStatus.success:
        return AppTheme.successColor;
      case BuildStatus.failed:
        return AppTheme.errorColor;
      case BuildStatus.canceled:
        return Colors.grey;
    }
  }

  Color _getDeploymentStatusColor(DeploymentStatus status) {
    switch (status) {
      case DeploymentStatus.inProgress:
        return AppTheme.deployingColor;
      case DeploymentStatus.success:
        return AppTheme.successColor;
      case DeploymentStatus.failed:
        return AppTheme.errorColor;
      case DeploymentStatus.rolledBack:
        return AppTheme.warningColor;
      case DeploymentStatus.canceled:
        return Colors.grey;
    }
  }

  Color _getServiceStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.starting:
        return AppTheme.buildingColor;
      case ServiceStatus.running:
        return AppTheme.successColor;
      case ServiceStatus.degraded:
        return AppTheme.warningColor;
      case ServiceStatus.stopped:
        return Colors.grey;
      case ServiceStatus.failed:
        return AppTheme.errorColor;
    }
  }

  Color _getHealthCheckStatusColor(HealthCheckStatus status) {
    switch (status) {
      case HealthCheckStatus.healthy:
        return AppTheme.successColor;
      case HealthCheckStatus.unhealthy:
        return AppTheme.errorColor;
      case HealthCheckStatus.warning:
        return AppTheme.warningColor;
      case HealthCheckStatus.unknown:
        return Colors.grey;
    }
  }

  Color _getActivityStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.info:
        return AppTheme.infoColor;
      case ActivityStatus.success:
        return AppTheme.successColor;
      case ActivityStatus.warning:
        return AppTheme.warningColor;
      case ActivityStatus.error:
        return AppTheme.errorColor;
    }
  }
}
