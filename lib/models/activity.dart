class Activity {
  final String id;
  final DateTime timestamp;
  final ActivityType type;
  final String repositoryId;
  final String? buildId;
  final String? deploymentId;
  final String? serviceId;
  final String message;
  final String user;
  final ActivityStatus status;

  Activity({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.repositoryId,
    this.buildId,
    this.deploymentId,
    this.serviceId,
    required this.message,
    required this.user,
    required this.status,
  });
}

enum ActivityType {
  repositoryAdded,
  buildStarted,
  buildCompleted,
  deploymentStarted,
  deploymentCompleted,
  serviceStarted,
  serviceStopped,
  serviceHealthChanged,
  configurationChanged,
  userAction,
}

extension ActivityTypeExtension on ActivityType {
  String get name {
    switch (this) {
      case ActivityType.repositoryAdded:
        return 'Repository Added';
      case ActivityType.buildStarted:
        return 'Build Started';
      case ActivityType.buildCompleted:
        return 'Build Completed';
      case ActivityType.deploymentStarted:
        return 'Deployment Started';
      case ActivityType.deploymentCompleted:
        return 'Deployment Completed';
      case ActivityType.serviceStarted:
        return 'Service Started';
      case ActivityType.serviceStopped:
        return 'Service Stopped';
      case ActivityType.serviceHealthChanged:
        return 'Service Health Changed';
      case ActivityType.configurationChanged:
        return 'Configuration Changed';
      case ActivityType.userAction:
        return 'User Action';
    }
  }
}

enum ActivityStatus {
  info,
  success,
  warning,
  error,
}

extension ActivityStatusExtension on ActivityStatus {
  String get name {
    switch (this) {
      case ActivityStatus.info:
        return 'Info';
      case ActivityStatus.success:
        return 'Success';
      case ActivityStatus.warning:
        return 'Warning';
      case ActivityStatus.error:
        return 'Error';
    }
  }
}
