class Service {
  final String id;
  final String name;
  final String repositoryId;
  final String deploymentId;
  final String environment;
  final ServiceStatus status;
  final DateTime startTime;
  final Map<String, double> resourceUsage;
  final List<ServiceHealthCheck> healthChecks;
  final String containerImage;
  final String version;
  final Map<String, String> environmentVariables;
  final List<ServicePort> ports;

  Service({
    required this.id,
    required this.name,
    required this.repositoryId,
    required this.deploymentId,
    required this.environment,
    required this.status,
    required this.startTime,
    required this.resourceUsage,
    required this.healthChecks,
    required this.containerImage,
    required this.version,
    required this.environmentVariables,
    required this.ports,
  });

  Duration get uptime => DateTime.now().difference(startTime);

  bool get isHealthy => 
      healthChecks.every((check) => check.status == HealthCheckStatus.healthy);
}

enum ServiceStatus {
  starting,
  running,
  degraded,
  stopped,
  failed,
}

extension ServiceStatusExtension on ServiceStatus {
  String get name {
    switch (this) {
      case ServiceStatus.starting:
        return 'Starting';
      case ServiceStatus.running:
        return 'Running';
      case ServiceStatus.degraded:
        return 'Degraded';
      case ServiceStatus.stopped:
        return 'Stopped';
      case ServiceStatus.failed:
        return 'Failed';
    }
  }
}

class ServiceHealthCheck {
  final String name;
  final HealthCheckStatus status;
  final DateTime lastChecked;
  final String details;

  ServiceHealthCheck({
    required this.name,
    required this.status,
    required this.lastChecked,
    required this.details,
  });
}

enum HealthCheckStatus {
  healthy,
  unhealthy,
  warning,
  unknown,
}

extension HealthCheckStatusExtension on HealthCheckStatus {
  String get name {
    switch (this) {
      case HealthCheckStatus.healthy:
        return 'Healthy';
      case HealthCheckStatus.unhealthy:
        return 'Unhealthy';
      case HealthCheckStatus.warning:
        return 'Warning';
      case HealthCheckStatus.unknown:
        return 'Unknown';
    }
  }
}

class ServicePort {
  final int internal;
  final int external;
  final String protocol;

  ServicePort({
    required this.internal,
    required this.external,
    required this.protocol,
  });

  @override
  String toString() => '$external:$internal/$protocol';
}
