import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'status_badge.dart';

class RepositoryCard extends StatelessWidget {
  final Repository repository;
  final VoidCallback onTap;
  final VoidCallback? onBuild;
  final VoidCallback? onDeploy;
  final VoidCallback? onMonitor;

  const RepositoryCard({
    super.key,
    required this.repository,
    required this.onTap,
    this.onBuild,
    this.onDeploy,
    this.onMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  StatusBadge(status: repository.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Branch: ${repository.branch}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last commit: ${_formatDate(repository.lastCommitDate)}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                repository.lastCommitMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'By: ${repository.lastCommitAuthor}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.build,
                    label: 'Build',
                    onPressed: onBuild,
                  ),
                  _buildActionButton(
                    icon: Icons.rocket_launch,
                    label: 'Deploy',
                    onPressed: onDeploy,
                  ),
                  _buildActionButton(
                    icon: Icons.monitor_heart,
                    label: 'Monitor',
                    onPressed: onMonitor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
