import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class MockDataService {
  static final Random random = Random();
  static final Faker faker = Faker();

  // Generate a random repository
  static Repository generateRepository() {
    final name = faker.internet.domainWord();
    final owner = faker.internet.userName();
    final statuses = RepositoryStatus.values;

    return Repository(
      id: faker.guid.guid(),
      name: name,
      owner: owner,
      url: 'https://github.com/$owner/$name',
      branch: 'main',
      lastCommitDate: faker.date.dateTime(minYear: 2023, maxYear: 2024),
      lastCommitMessage: faker.lorem.sentence(),
      lastCommitAuthor: faker.person.name(),
      status: statuses[random.nextInt(statuses.length)],
      environments: ['dev', 'staging', 'production'].sublist(0, random.nextInt(3) + 1),
      hasDockerComposeFile: random.nextBool(),
    );
  }

  // Generate a list of repositories
  static List<Repository> generateRepositories(int count) {
    return List.generate(count, (_) => generateRepository());
  }

  // Generate a random build
  static Build generateBuild(String repositoryId) {
    final statuses = BuildStatus.values;
    final status = statuses[random.nextInt(statuses.length)];
    final startTime = faker.date.dateTime(minYear: 2023, maxYear: 2024);
    final endTime = status == BuildStatus.inProgress
        ? null
        : startTime.add(Duration(minutes: random.nextInt(30) + 1));

    return Build(
      id: faker.guid.guid(),
      repositoryId: repositoryId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      branch: 'main',
      commitId: faker.guid.guid().substring(0, 7),
      commitMessage: faker.lorem.sentence(),
      triggeredBy: faker.person.name(),
      stages: _generateBuildStages(status),
      buildArgs: {
        'NODE_ENV': 'production',
        'BUILD_NUMBER': random.nextInt(1000).toString(),
      },
      cacheEnabled: random.nextBool(),
    );
  }

  // Generate build stages
  static List<BuildStage> _generateBuildStages(BuildStatus buildStatus) {
    final stages = ['Clone', 'Build', 'Test', 'Package'];
    final result = <BuildStage>[];

    DateTime startTime = faker.date.dateTime(minYear: 2023, maxYear: 2024);

    for (int i = 0; i < stages.length; i++) {
      final stageName = stages[i];
      BuildStageStatus status;

      if (buildStatus == BuildStatus.inProgress) {
        if (i < result.length) {
          status = BuildStageStatus.success;
        } else if (i == result.length) {
          status = BuildStageStatus.inProgress;
        } else {
          status = BuildStageStatus.waiting;
        }
      } else if (buildStatus == BuildStatus.success) {
        status = BuildStageStatus.success;
      } else if (buildStatus == BuildStatus.failed) {
        if (i < result.length) {
          status = BuildStageStatus.success;
        } else if (i == result.length) {
          status = BuildStageStatus.failed;
        } else {
          status = BuildStageStatus.skipped;
        }
      } else {
        status = BuildStageStatus.skipped;
      }

      final stageDuration = Duration(minutes: random.nextInt(10) + 1);
      final endTime = status == BuildStageStatus.inProgress || status == BuildStageStatus.waiting
          ? null
          : startTime.add(stageDuration);

      result.add(BuildStage(
        name: stageName,
        startTime: status == BuildStageStatus.waiting ? startTime : startTime,
        endTime: endTime,
        status: status,
        logs: _generateLogs(stageName, status),
      ));

      if (endTime != null) {
        startTime = endTime;
      }

      if (status == BuildStageStatus.failed) {
        break;
      }
    }

    return result;
  }

  // Generate random logs
  static List<String> _generateLogs(String stageName, BuildStageStatus status) {
    final logCount = random.nextInt(10) + 5;
    final logs = <String>[];

    logs.add('Starting $stageName stage...');

    for (int i = 0; i < logCount; i++) {
      logs.add(faker.lorem.sentence());
    }

    if (status == BuildStageStatus.success) {
      logs.add('$stageName completed successfully');
    } else if (status == BuildStageStatus.failed) {
      logs.add('ERROR: ${faker.lorem.sentence()}');
      logs.add('$stageName failed');
    } else if (status == BuildStageStatus.inProgress) {
      logs.add('$stageName in progress...');
    }

    return logs;
  }

  // Generate a list of builds for a repository
  static List<Build> generateBuildsForRepository(String repositoryId, int count) {
    return List.generate(count, (_) => generateBuild(repositoryId));
  }

  // Generate a random deployment
  static Deployment generateDeployment(String repositoryId, String buildId) {
    final statuses = DeploymentStatus.values;
    final status = statuses[random.nextInt(statuses.length)];
    final strategies = DeploymentStrategy.values;
    final strategy = strategies[random.nextInt(strategies.length)];
    final environments = ['dev', 'staging', 'production'];
    final environment = environments[random.nextInt(environments.length)];
    final startTime = faker.date.dateTime(minYear: 2023, maxYear: 2024);
    final endTime = status == DeploymentStatus.inProgress
        ? null
        : startTime.add(Duration(minutes: random.nextInt(20) + 1));

    return Deployment(
      id: faker.guid.guid(),
      repositoryId: repositoryId,
      buildId: buildId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      strategy: strategy,
      environment: environment,
      version: '1.${random.nextInt(10)}.${random.nextInt(10)}',
      deployedBy: faker.person.name(),
      steps: _generateDeploymentSteps(status, strategy),
      canRollback: status == DeploymentStatus.success,
    );
  }

  // Generate deployment steps
  static List<DeploymentStep> _generateDeploymentSteps(
      DeploymentStatus deploymentStatus, DeploymentStrategy strategy) {
    final directSteps = ['Prepare', 'Deploy', 'Verify'];
    final blueGreenSteps = ['Prepare', 'Deploy Blue', 'Test Blue', 'Switch Traffic', 'Verify'];
    final steps = strategy == DeploymentStrategy.direct ? directSteps : blueGreenSteps;
    final result = <DeploymentStep>[];

    DateTime startTime = faker.date.dateTime(minYear: 2023, maxYear: 2024);

    for (int i = 0; i < steps.length; i++) {
      final stepName = steps[i];
      DeploymentStepStatus status;

      if (deploymentStatus == DeploymentStatus.inProgress) {
        if (i < result.length) {
          status = DeploymentStepStatus.success;
        } else if (i == result.length) {
          status = DeploymentStepStatus.inProgress;
        } else {
          status = DeploymentStepStatus.waiting;
        }
      } else if (deploymentStatus == DeploymentStatus.success) {
        status = DeploymentStepStatus.success;
      } else if (deploymentStatus == DeploymentStatus.failed) {
        if (i < result.length) {
          status = DeploymentStepStatus.success;
        } else if (i == result.length) {
          status = DeploymentStepStatus.failed;
        } else {
          status = DeploymentStepStatus.skipped;
        }
      } else {
        status = DeploymentStepStatus.skipped;
      }

      final stepDuration = Duration(minutes: random.nextInt(5) + 1);
      final endTime = status == DeploymentStepStatus.inProgress || status == DeploymentStepStatus.waiting
          ? null
          : startTime.add(stepDuration);

      result.add(DeploymentStep(
        name: stepName,
        startTime: status == DeploymentStepStatus.waiting ? startTime : startTime,
        endTime: endTime,
        status: status,
        logs: _generateLogs(stepName, _mapToDeploymentStepStatus(status)),
      ));

      if (endTime != null) {
        startTime = endTime;
      }

      if (status == DeploymentStepStatus.failed) {
        break;
      }
    }

    return result;
  }

  // Map deployment step status to build stage status for log generation
  static BuildStageStatus _mapToDeploymentStepStatus(DeploymentStepStatus status) {
    switch (status) {
      case DeploymentStepStatus.waiting:
        return BuildStageStatus.waiting;
      case DeploymentStepStatus.inProgress:
        return BuildStageStatus.inProgress;
      case DeploymentStepStatus.success:
        return BuildStageStatus.success;
      case DeploymentStepStatus.failed:
        return BuildStageStatus.failed;
      case DeploymentStepStatus.skipped:
        return BuildStageStatus.skipped;
    }
  }
}
