import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'mock_data_service.dart';
import 'mock_service_data.dart';

class RepositoryService extends ChangeNotifier {
  List<Repository> _repositories = [];
  Map<String, List<Build>> _builds = {};
  Map<String, List<Deployment>> _deployments = {};
  Map<String, List<Service>> _services = {};
  List<Activity> _activities = [];

  // Getters
  List<Repository> get repositories => _repositories;
  List<Build> getBuildsForRepository(String repositoryId) => _builds[repositoryId] ?? [];
  List<Deployment> getDeploymentsForRepository(String repositoryId) => _deployments[repositoryId] ?? [];
  List<Service> getServicesForRepository(String repositoryId) => _services[repositoryId] ?? [];
  List<Activity> get activities => _activities;

  // Initialize with mock data
  Future<void> initialize() async {
    // Generate repositories
    _repositories = MockDataService.generateRepositories(5);

    // Generate builds, deployments, and services for each repository
    for (final repository in _repositories) {
      final builds = MockDataService.generateBuildsForRepository(repository.id, 10);
      _builds[repository.id] = builds;

      final deployments = <Deployment>[];
      final services = <Service>[];

      for (final build in builds.take(5)) {
        final deployment = MockDataService.generateDeployment(repository.id, build.id);
        deployments.add(deployment);

        final serviceCount = repository.environments.length;
        services.addAll(
          MockServiceData.generateServicesForDeployment(
            repository.id,
            deployment.id,
            deployment.environment,
            serviceCount
          )
        );
      }

      _deployments[repository.id] = deployments;
      _services[repository.id] = services;
    }

    // Generate activities
    _activities = MockServiceData.generateActivities(20);
    _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Start periodic updates
    _startPeriodicUpdates();
  }

  // Simulate real-time updates
  void _startPeriodicUpdates() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      _updateRandomRepository();
      _updateRandomBuild();
      _updateRandomDeployment();
      _updateRandomService();
      _addRandomActivity();
      notifyListeners();
    });
  }

  // Update a random repository
  void _updateRandomRepository() {
    if (_repositories.isEmpty) return;

    final random = MockDataService.random;
    final index = random.nextInt(_repositories.length);
    final repository = _repositories[index];

    // Simulate status changes
    final statuses = RepositoryStatus.values;
    final newStatus = statuses[random.nextInt(statuses.length)];

    _repositories[index] = Repository(
      id: repository.id,
      name: repository.name,
      owner: repository.owner,
      url: repository.url,
      branch: repository.branch,
      lastCommitDate: DateTime.now(),
      lastCommitMessage: MockDataService.faker.lorem.sentence(),
      lastCommitAuthor: repository.lastCommitAuthor,
      status: newStatus,
      environments: repository.environments,
      hasDockerComposeFile: repository.hasDockerComposeFile,
    );
  }

  // Update a random build
  void _updateRandomBuild() {
    if (_repositories.isEmpty) return;

    final random = MockDataService.random;
    final repositoryIndex = random.nextInt(_repositories.length);
    final repositoryId = _repositories[repositoryIndex].id;

    final builds = _builds[repositoryId];
    if (builds == null || builds.isEmpty) return;

    final buildIndex = random.nextInt(builds.length);
    final build = builds[buildIndex];

    // Only update in-progress builds
    if (build.status == BuildStatus.inProgress) {
      final newStatus = random.nextBool() ? BuildStatus.success : BuildStatus.failed;

      builds[buildIndex] = Build(
        id: build.id,
        repositoryId: build.repositoryId,
        startTime: build.startTime,
        endTime: DateTime.now(),
        status: newStatus,
        branch: build.branch,
        commitId: build.commitId,
        commitMessage: build.commitMessage,
        triggeredBy: build.triggeredBy,
        stages: _updateBuildStages(build.stages, newStatus),
        buildArgs: build.buildArgs,
        cacheEnabled: build.cacheEnabled,
      );
    }
  }

  // Update build stages
  List<BuildStage> _updateBuildStages(List<BuildStage> stages, BuildStatus newStatus) {
    final result = <BuildStage>[];

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];

      if (stage.status == BuildStageStatus.inProgress) {
        // Complete the in-progress stage
        result.add(BuildStage(
          name: stage.name,
          startTime: stage.startTime,
          endTime: DateTime.now(),
          status: newStatus == BuildStatus.success ? BuildStageStatus.success : BuildStageStatus.failed,
          logs: [...stage.logs, '${stage.name} ${newStatus == BuildStatus.success ? 'completed successfully' : 'failed'}'],
        ));

        // If the build failed, skip remaining stages
        if (newStatus == BuildStatus.failed) {
          for (int j = i + 1; j < stages.length; j++) {
            result.add(BuildStage(
              name: stages[j].name,
              startTime: stages[j].startTime,
              endTime: null,
              status: BuildStageStatus.skipped,
              logs: [],
            ));
          }
          break;
        }
      } else if (stage.status == BuildStageStatus.waiting && i > 0 && result[i - 1].status == BuildStageStatus.success) {
        // Start the next waiting stage
        result.add(BuildStage(
          name: stage.name,
          startTime: DateTime.now(),
          endTime: null,
          status: BuildStageStatus.inProgress,
          logs: ['Starting ${stage.name} stage...'],
        ));
      } else {
        result.add(stage);
      }
    }

    return result;
  }

  // Update a random deployment
  void _updateRandomDeployment() {
    if (_repositories.isEmpty) return;

    final random = MockDataService.random;
    final repositoryIndex = random.nextInt(_repositories.length);
    final repositoryId = _repositories[repositoryIndex].id;

    final deployments = _deployments[repositoryId];
    if (deployments == null || deployments.isEmpty) return;

    final deploymentIndex = random.nextInt(deployments.length);
    final deployment = deployments[deploymentIndex];

    // Only update in-progress deployments
    if (deployment.status == DeploymentStatus.inProgress) {
      final newStatus = random.nextBool() ? DeploymentStatus.success : DeploymentStatus.failed;

      deployments[deploymentIndex] = Deployment(
        id: deployment.id,
        repositoryId: deployment.repositoryId,
        buildId: deployment.buildId,
        startTime: deployment.startTime,
        endTime: DateTime.now(),
        status: newStatus,
        strategy: deployment.strategy,
        environment: deployment.environment,
        version: deployment.version,
        deployedBy: deployment.deployedBy,
        steps: _updateDeploymentSteps(deployment.steps, newStatus),
        canRollback: newStatus == DeploymentStatus.success,
      );
    }
  }

  // Update deployment steps
  List<DeploymentStep> _updateDeploymentSteps(List<DeploymentStep> steps, DeploymentStatus newStatus) {
    final result = <DeploymentStep>[];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];

      if (step.status == DeploymentStepStatus.inProgress) {
        // Complete the in-progress step
        result.add(DeploymentStep(
          name: step.name,
          startTime: step.startTime,
          endTime: DateTime.now(),
          status: newStatus == DeploymentStatus.success ? DeploymentStepStatus.success : DeploymentStepStatus.failed,
          logs: [...step.logs, '${step.name} ${newStatus == DeploymentStatus.success ? 'completed successfully' : 'failed'}'],
        ));

        // If the deployment failed, skip remaining steps
        if (newStatus == DeploymentStatus.failed) {
          for (int j = i + 1; j < steps.length; j++) {
            result.add(DeploymentStep(
              name: steps[j].name,
              startTime: steps[j].startTime,
              endTime: null,
              status: DeploymentStepStatus.skipped,
              logs: [],
            ));
          }
          break;
        }
      } else if (step.status == DeploymentStepStatus.waiting && i > 0 && result[i - 1].status == DeploymentStepStatus.success) {
        // Start the next waiting step
        result.add(DeploymentStep(
          name: step.name,
          startTime: DateTime.now(),
          endTime: null,
          status: DeploymentStepStatus.inProgress,
          logs: ['Starting ${step.name} step...'],
        ));
      } else {
        result.add(step);
      }
    }

    return result;
  }

  // Update a random service
  void _updateRandomService() {
    if (_repositories.isEmpty) return;

    final random = MockDataService.random;
    final repositoryIndex = random.nextInt(_repositories.length);
    final repositoryId = _repositories[repositoryIndex].id;

    final services = _services[repositoryId];
    if (services == null || services.isEmpty) return;

    final serviceIndex = random.nextInt(services.length);
    final service = services[serviceIndex];

    // Update service status and resource usage
    final statuses = ServiceStatus.values;
    final newStatus = statuses[random.nextInt(statuses.length)];

    services[serviceIndex] = Service(
      id: service.id,
      name: service.name,
      repositoryId: service.repositoryId,
      deploymentId: service.deploymentId,
      environment: service.environment,
      status: newStatus,
      startTime: service.startTime,
      resourceUsage: {
        'cpu': random.nextDouble() * 100,
        'memory': random.nextDouble() * 100,
        'disk': random.nextDouble() * 100,
        'network': random.nextDouble() * 100,
      },
      healthChecks: MockServiceData.generateHealthChecks(newStatus),
      containerImage: service.containerImage,
      version: service.version,
      environmentVariables: service.environmentVariables,
      ports: service.ports,
    );
  }

  // Add a random activity
  void _addRandomActivity() {
    final activity = MockServiceData.generateActivity();
    _activities.insert(0, activity);

    // Keep only the latest 100 activities
    if (_activities.length > 100) {
      _activities = _activities.sublist(0, 100);
    }
  }

  // Trigger a new build for a repository
  void triggerBuild(String repositoryId) {
    final repository = _repositories.firstWhere(
      (repo) => repo.id == repositoryId,
      orElse: () => throw Exception('Repository not found'),
    );

    // Update repository status to building
    final repoIndex = _repositories.indexWhere((repo) => repo.id == repositoryId);
    _repositories[repoIndex] = Repository(
      id: repository.id,
      name: repository.name,
      owner: repository.owner,
      url: repository.url,
      branch: repository.branch,
      lastCommitDate: repository.lastCommitDate,
      lastCommitMessage: repository.lastCommitMessage,
      lastCommitAuthor: repository.lastCommitAuthor,
      status: RepositoryStatus.building,
      environments: repository.environments,
      hasDockerComposeFile: repository.hasDockerComposeFile,
    );

    // Create a new build with inProgress status
    final newBuild = Build(
      id: MockDataService.faker.guid.guid(),
      repositoryId: repositoryId,
      startTime: DateTime.now(),
      endTime: null,
      status: BuildStatus.inProgress,
      branch: 'main',
      commitId: MockDataService.faker.guid.guid().substring(0, 7),
      commitMessage: 'Manual build triggered',
      triggeredBy: 'User',
      stages: _generateInitialBuildStages(),
      buildArgs: {
        'NODE_ENV': 'production',
        'BUILD_NUMBER': MockDataService.random.nextInt(1000).toString(),
      },
      cacheEnabled: true,
    );

    // Add the new build to the repository's builds
    final builds = _builds[repositoryId] ?? [];
    builds.insert(0, newBuild);
    _builds[repositoryId] = builds;

    // Add a build started activity
    _activities.insert(
      0,
      Activity(
        id: MockDataService.faker.guid.guid(),
        timestamp: DateTime.now(),
        type: ActivityType.buildStarted,
        repositoryId: repositoryId,
        buildId: newBuild.id,
        deploymentId: null,
        serviceId: null,
        message: 'Build started for ${repository.name}',
        user: 'User',
        status: ActivityStatus.info,
      ),
    );

    notifyListeners();
  }

  // Generate initial build stages for a new build
  List<BuildStage> _generateInitialBuildStages() {
    final stages = ['Clone', 'Build', 'Test', 'Package'];
    final result = <BuildStage>[];
    final now = DateTime.now();

    // First stage (Clone) is in progress
    result.add(BuildStage(
      name: stages[0],
      startTime: now,
      endTime: null,
      status: BuildStageStatus.inProgress,
      logs: ['Starting ${stages[0]} stage...'],
    ));

    // Other stages are waiting
    for (int i = 1; i < stages.length; i++) {
      result.add(BuildStage(
        name: stages[i],
        startTime: now,
        endTime: null,
        status: BuildStageStatus.waiting,
        logs: [],
      ));
    }

    return result;
  }
}
