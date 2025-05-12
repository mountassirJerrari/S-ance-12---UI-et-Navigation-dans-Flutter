import 'dart:math';
import 'package:faker/faker.dart';
import '../models/models.dart';

class MockServiceData {
  static final Random random = Random();
  static final Faker faker = Faker();

  // Generate a random service
  static Service generateService(String repositoryId, String deploymentId, String environment) {
    final statuses = ServiceStatus.values;
    final status = statuses[random.nextInt(statuses.length)];

    return Service(
      id: faker.guid.guid(),
      name: faker.internet.domainWord(),
      repositoryId: repositoryId,
      deploymentId: deploymentId,
      environment: environment,
      status: status,
      startTime: faker.date.dateTime(minYear: 2023, maxYear: 2024),
      resourceUsage: {
        'cpu': random.nextDouble() * 100,
        'memory': random.nextDouble() * 100,
        'disk': random.nextDouble() * 100,
        'network': random.nextDouble() * 100,
      },
      healthChecks: generateHealthChecks(status),
      containerImage: 'docker.io/${faker.internet.domainWord()}/${faker.internet.domainWord()}:${random.nextInt(10)}.${random.nextInt(10)}',
      version: '1.${random.nextInt(10)}.${random.nextInt(10)}',
      environmentVariables: {
        'NODE_ENV': environment,
        'LOG_LEVEL': 'info',
        'PORT': '8080',
      },
      ports: generatePorts(),
    );
  }

  // Generate health checks
  static List<ServiceHealthCheck> generateHealthChecks(ServiceStatus status) {
    final healthCheckCount = random.nextInt(3) + 1;
    final result = <ServiceHealthCheck>[];

    for (int i = 0; i < healthCheckCount; i++) {
      HealthCheckStatus healthStatus;

      if (status == ServiceStatus.running) {
        healthStatus = HealthCheckStatus.healthy;
      } else if (status == ServiceStatus.degraded) {
        healthStatus = i == 0 ? HealthCheckStatus.warning : HealthCheckStatus.healthy;
      } else if (status == ServiceStatus.failed) {
        healthStatus = HealthCheckStatus.unhealthy;
      } else {
        healthStatus = HealthCheckStatus.unknown;
      }

      result.add(ServiceHealthCheck(
        name: ['HTTP', 'Database', 'Redis', 'API'][i % 4],
        status: healthStatus,
        lastChecked: DateTime.now().subtract(Duration(seconds: random.nextInt(60))),
        details: healthStatus == HealthCheckStatus.healthy
            ? 'OK'
            : faker.lorem.sentence(),
      ));
    }

    return result;
  }

  // Generate ports
  static List<ServicePort> generatePorts() {
    final portCount = random.nextInt(2) + 1;
    final result = <ServicePort>[];

    for (int i = 0; i < portCount; i++) {
      result.add(ServicePort(
        internal: 8080 + i,
        external: 30000 + random.nextInt(1000),
        protocol: i == 0 ? 'tcp' : 'udp',
      ));
    }

    return result;
  }

  // Generate a list of services for a deployment
  static List<Service> generateServicesForDeployment(
      String repositoryId, String deploymentId, String environment, int count) {
    return List.generate(
        count, (_) => generateService(repositoryId, deploymentId, environment));
  }

  // Generate a random activity
  static Activity generateActivity() {
    final types = ActivityType.values;
    final type = types[random.nextInt(types.length)];
    final statuses = ActivityStatus.values;
    final status = statuses[random.nextInt(statuses.length)];

    return Activity(
      id: faker.guid.guid(),
      timestamp: faker.date.dateTime(minYear: 2023, maxYear: 2024),
      type: type,
      repositoryId: faker.guid.guid(),
      buildId: type == ActivityType.buildStarted || type == ActivityType.buildCompleted
          ? faker.guid.guid()
          : null,
      deploymentId: type == ActivityType.deploymentStarted || type == ActivityType.deploymentCompleted
          ? faker.guid.guid()
          : null,
      serviceId: type == ActivityType.serviceStarted || type == ActivityType.serviceStopped || type == ActivityType.serviceHealthChanged
          ? faker.guid.guid()
          : null,
      message: generateActivityMessage(type, status),
      user: faker.person.name(),
      status: status,
    );
  }

  // Generate activity message
  static String generateActivityMessage(ActivityType type, ActivityStatus status) {
    final repoName = faker.internet.domainWord();

    switch (type) {
      case ActivityType.repositoryAdded:
        return 'Repository $repoName added';
      case ActivityType.buildStarted:
        return 'Build started for $repoName';
      case ActivityType.buildCompleted:
        return 'Build ${status == ActivityStatus.success ? 'completed successfully' : 'failed'} for $repoName';
      case ActivityType.deploymentStarted:
        return 'Deployment started for $repoName to ${['dev', 'staging', 'production'][random.nextInt(3)]}';
      case ActivityType.deploymentCompleted:
        return 'Deployment ${status == ActivityStatus.success ? 'completed successfully' : 'failed'} for $repoName';
      case ActivityType.serviceStarted:
        return 'Service ${faker.internet.domainWord()} started';
      case ActivityType.serviceStopped:
        return 'Service ${faker.internet.domainWord()} stopped';
      case ActivityType.serviceHealthChanged:
        return 'Service ${faker.internet.domainWord()} health changed to ${status.name}';
      case ActivityType.configurationChanged:
        return 'Configuration changed for $repoName';
      case ActivityType.userAction:
        return '${faker.person.name()} performed action on $repoName';
    }
  }

  // Generate a list of activities
  static List<Activity> generateActivities(int count) {
    return List.generate(count, (_) => generateActivity());
  }
}
