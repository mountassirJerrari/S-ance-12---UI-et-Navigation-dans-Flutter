import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/repository_service.dart';
import '../widgets/widgets.dart';

class BuildsScreen extends StatelessWidget {
  const BuildsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repositoryService = Provider.of<RepositoryService>(context);
    final repositories = repositoryService.repositories;

    if (repositories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get all builds from all repositories
    final allBuilds = <Build>[];
    for (final repository in repositories) {
      allBuilds.addAll(repositoryService.getBuildsForRepository(repository.id));
    }

    // Sort builds by start time (newest first)
    allBuilds.sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Builds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allBuilds.length,
        itemBuilder: (context, index) {
          final build = allBuilds[index];
          final repository = repositories.firstWhere(
            (repo) => repo.id == build.repositoryId,
          );
          return _buildBuildCard(context, build, repository);
        },
      ),
    );
  }

  Widget _buildBuildCard(BuildContext context, Build build, Repository repository) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${repository.owner}/${repository.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: build.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Commit: ${build.commitId} - ${build.commitMessage}',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Branch: ${build.branch}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Started: ${_formatDate(build.startTime)}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (build.endTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${_formatDuration(build.duration)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildBuildStages(context, build),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View build logs
                  },
                  icon: const Icon(Icons.subject, size: 16),
                  label: const Text('Logs'),
                ),
                const SizedBox(width: 8),
                if (build.status == BuildStatus.success)
                  TextButton.icon(
                    onPressed: () {
                      // Deploy build
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deploying build...')),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch, size: 16),
                    label: const Text('Deploy'),
                  ),
                if (build.status == BuildStatus.inProgress)
                  TextButton.icon(
                    onPressed: () {
                      // Cancel build
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Canceling build...')),
                      );
                    },
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel'),
                  ),
                if (build.status == BuildStatus.failed)
                  TextButton.icon(
                    onPressed: () {
                      // Retry build
                      final repositoryService = Provider.of<RepositoryService>(context, listen: false);
                      repositoryService.triggerBuild(build.repositoryId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retrying build...')),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildStages(BuildContext context, Build build) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: build.stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isLast = index == build.stages.length - 1;

              return PipelineStage(
                name: stage.name,
                status: _mapBuildStageStatus(stage.status),
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  PipelineStageStatus _mapBuildStageStatus(BuildStageStatus status) {
    switch (status) {
      case BuildStageStatus.waiting:
        return PipelineStageStatus.notStarted;
      case BuildStageStatus.inProgress:
        return PipelineStageStatus.inProgress;
      case BuildStageStatus.success:
        return PipelineStageStatus.success;
      case BuildStageStatus.failed:
        return PipelineStageStatus.failed;
      case BuildStageStatus.skipped:
        return PipelineStageStatus.skipped;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy HH:mm').format(date);
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
