import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/repository_service.dart';
import '../widgets/widgets.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repositoryService = Provider.of<RepositoryService>(context);
    final repositories = repositoryService.repositories;

    if (repositories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get all services from all repositories
    final allServices = <Service>[];
    for (final repository in repositories) {
      allServices.addAll(repositoryService.getServicesForRepository(repository.id));
    }

    // Sort services by status (critical first)
    allServices.sort((a, b) {
      final aValue = _getStatusPriority(a.status);
      final bValue = _getStatusPriority(b.status);
      return aValue.compareTo(bValue);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allServices.length,
        itemBuilder: (context, index) {
          final service = allServices[index];
          final repository = repositories.firstWhere(
            (repo) => repo.id == service.repositoryId,
          );
          return _buildServiceCard(context, service, repository);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service, Repository repository) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${repository.owner}/${repository.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: service.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Environment: ${service.environment}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Image: ${service.containerImage}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Uptime: ${_formatDuration(service.uptime)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildHealthChecks(context, service),
            const SizedBox(height: 16),
            _buildResourceUsage(context, service),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View logs
                  },
                  icon: const Icon(Icons.subject, size: 16),
                  label: const Text('Logs'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Restart service
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restarting ${service.name}...')),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Restart'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Stop service
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stopping ${service.name}...')),
                    );
                  },
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChecks(BuildContext context, Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Checks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...service.healthChecks.map((check) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  StatusBadge(status: check.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          check.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          check.details,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimeAgo(check.lastChecked),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildResourceUsage(BuildContext context, Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resource Usage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ResourceUsageChart(
            resourceUsage: service.resourceUsage,
            title: '',
          ),
        ),
      ],
    );
  }

  int _getStatusPriority(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.failed:
        return 0;
      case ServiceStatus.degraded:
        return 1;
      case ServiceStatus.starting:
        return 2;
      case ServiceStatus.stopped:
        return 3;
      case ServiceStatus.running:
        return 4;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
