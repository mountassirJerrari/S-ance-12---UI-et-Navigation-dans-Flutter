class Build {
  final String id;
  final String repositoryId;
  final DateTime startTime;
  final DateTime? endTime;
  final BuildStatus status;
  final String branch;
  final String commitId;
  final String commitMessage;
  final String triggeredBy;
  final List<BuildStage> stages;
  final Map<String, String> buildArgs;
  final bool cacheEnabled;

  Build({
    required this.id,
    required this.repositoryId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.branch,
    required this.commitId,
    required this.commitMessage,
    required this.triggeredBy,
    required this.stages,
    required this.buildArgs,
    required this.cacheEnabled,
  });

  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  bool get isCompleted => status != BuildStatus.inProgress;
}

enum BuildStatus {
  inProgress,
  success,
  failed,
  canceled,
}

extension BuildStatusExtension on BuildStatus {
  String get name {
    switch (this) {
      case BuildStatus.inProgress:
        return 'In Progress';
      case BuildStatus.success:
        return 'Success';
      case BuildStatus.failed:
        return 'Failed';
      case BuildStatus.canceled:
        return 'Canceled';
    }
  }
}

class BuildStage {
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final BuildStageStatus status;
  final List<String> logs;

  BuildStage({
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

enum BuildStageStatus {
  waiting,
  inProgress,
  success,
  failed,
  skipped,
}

extension BuildStageStatusExtension on BuildStageStatus {
  String get name {
    switch (this) {
      case BuildStageStatus.waiting:
        return 'Waiting';
      case BuildStageStatus.inProgress:
        return 'In Progress';
      case BuildStageStatus.success:
        return 'Success';
      case BuildStageStatus.failed:
        return 'Failed';
      case BuildStageStatus.skipped:
        return 'Skipped';
    }
  }
}
