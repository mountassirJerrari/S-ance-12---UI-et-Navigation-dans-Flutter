import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/repository_service.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repositoryService = Provider.of<RepositoryService>(context);
    final repositories = repositoryService.repositories;
    final activities = repositoryService.activities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CI/CD Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: repositories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPipelineOverview(context),
                  const SizedBox(height: 24),
                  _buildSummaryMetrics(context, repositories),
                  const SizedBox(height: 24),
                  _buildProjectsSection(context, repositories),
                  const SizedBox(height: 24),
                  _buildActivityFeed(context, activities),
                ],
              ),
            ),
    );
  }

  Widget _buildPipelineOverview(BuildContext context) {
    final repositoryService = Provider.of<RepositoryService>(context);
    final repositories = repositoryService.repositories;

    // Find any repository that is currently building
    Repository? buildingRepo;
    try {
      buildingRepo = repositories.firstWhere(
        (repo) => repo.status == RepositoryStatus.building,
      );
    } catch (e) {
      // No building repository found
      buildingRepo = null;
    }

    // If a repository is building, find its latest in-progress build
    Build? activeBuild;
    if (buildingRepo != null) {
      final builds = repositoryService.getBuildsForRepository(buildingRepo.id);
      try {
        activeBuild = builds.firstWhere(
          (build) => build.status == BuildStatus.inProgress,
        );
      } catch (e) {
        // No in-progress build found
        activeBuild = null;
      }
    }

    // Determine pipeline stages based on active build
    List<Map<String, dynamic>> pipelineStages = [
      {'name': 'Pull', 'status': PipelineStageStatus.notStarted},
      {'name': 'Build', 'status': PipelineStageStatus.notStarted},
      {'name': 'Test', 'status': PipelineStageStatus.notStarted},
      {'name': 'Deploy', 'status': PipelineStageStatus.notStarted},
      {'name': 'Monitor', 'status': PipelineStageStatus.notStarted},
    ];

    if (activeBuild != null) {
      // Map build stages to pipeline stages
      bool foundInProgress = false;
      for (int i = 0; i < activeBuild.stages.length && i < pipelineStages.length; i++) {
        final buildStage = activeBuild.stages[i];

        if (buildStage.status == BuildStageStatus.inProgress) {
          pipelineStages[i]['status'] = PipelineStageStatus.inProgress;
          foundInProgress = true;
        } else if (buildStage.status == BuildStageStatus.success) {
          pipelineStages[i]['status'] = PipelineStageStatus.success;
        } else if (buildStage.status == BuildStageStatus.failed) {
          pipelineStages[i]['status'] = PipelineStageStatus.failed;
        } else if (buildStage.status == BuildStageStatus.skipped) {
          pipelineStages[i]['status'] = PipelineStageStatus.skipped;
        } else if (!foundInProgress) {
          pipelineStages[i]['status'] = PipelineStageStatus.notStarted;
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pipeline Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: pipelineStages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stage = entry.value;
                  final isLast = index == pipelineStages.length - 1;

                  return PipelineStage(
                    name: stage['name'],
                    status: stage['status'],
                    isLast: isLast,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics(BuildContext context, List<Repository> repositories) {
    // Calculate metrics
    final successfulDeployments = 15;
    final failedBuilds = 3;
    final avgBuildTime = '5m 23s';

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Successful Deployments',
            successfulDeployments.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Failed Builds',
            failedBuilds.toString(),
            Icons.error,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Average Build Time',
            avgBuildTime,
            Icons.timer,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context, List<Repository> repositories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to all projects
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: repositories.length > 4 ? 4 : repositories.length,
          itemBuilder: (context, index) {
            final repository = repositories[index];
            return RepositoryCard(
              repository: repository,
              onTap: () {
                // Navigate to repository details
              },
              onBuild: () {
                // Trigger build
                final repositoryService = Provider.of<RepositoryService>(context, listen: false);
                repositoryService.triggerBuild(repository.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Building ${repository.name}...')),
                );
              },
              onDeploy: () {
                // Trigger deployment
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deploying ${repository.name}...')),
                );
              },
              onMonitor: () {
                // Navigate to monitoring
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Monitoring ${repository.name}...')),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityFeed(BuildContext context, List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to all activities
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length > 5 ? 5 : activities.length,
          itemBuilder: (context, index) {
            return ActivityFeedItem(activity: activities[index]);
          },
        ),
      ],
    );
  }
}
