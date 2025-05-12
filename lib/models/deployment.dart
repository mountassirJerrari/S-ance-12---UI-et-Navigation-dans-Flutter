class Deployment {
  final String id;
  final String repositoryId;
  final String buildId;
  final DateTime startTime;
  final DateTime? endTime;
  final DeploymentStatus status;
  final DeploymentStrategy strategy;
  final String environment;
  final String version;
  final String deployedBy;
  final List<DeploymentStep> steps;
  final bool canRollback;

  Deployment({
    required this.id,
    required this.repositoryId,
    required this.buildId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.strategy,
    required this.environment,
    required this.version,
    required this.deployedBy,
    required this.steps,
    required this.canRollback,
  });

  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  bool get isCompleted => 
      status == DeploymentStatus.success || 
      status == DeploymentStatus.failed || 
      status == DeploymentStatus.rolledBack;
}

enum DeploymentStatus {
  inProgress,
  success,
  failed,
  rolledBack,
  canceled,
}

extension DeploymentStatusExtension on DeploymentStatus {
  String get name {
    switch (this) {
      case DeploymentStatus.inProgress:
        return 'In Progress';
      case DeploymentStatus.success:
        return 'Success';
      case DeploymentStatus.failed:
        return 'Failed';
      case DeploymentStatus.rolledBack:
        return 'Rolled Back';
      case DeploymentStatus.canceled:
        return 'Canceled';
    }
  }
}

enum DeploymentStrategy {
  direct,
  blueGreen,
}

extension DeploymentStrategyExtension on DeploymentStrategy {
  String get name {
    switch (this) {
      case DeploymentStrategy.direct:
        return 'Direct Replace';
      case DeploymentStrategy.blueGreen:
        return 'Blue-Green';
    }
  }
}

class DeploymentStep {
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final DeploymentStepStatus status;
  final List<String> logs;

  DeploymentStep({
    required this.name,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.logs,
  });

  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }
}

enum DeploymentStepStatus {
  waiting,
  inProgress,
  success,
  failed,
  skipped,
}

extension DeploymentStepStatusExtension on DeploymentStepStatus {
  String get name {
    switch (this) {
      case DeploymentStepStatus.waiting:
        return 'Waiting';
      case DeploymentStepStatus.inProgress:
        return 'In Progress';
      case DeploymentStepStatus.success:
        return 'Success';
      case DeploymentStepStatus.failed:
        return 'Failed';
      case DeploymentStepStatus.skipped:
        return 'Skipped';
    }
  }
}
