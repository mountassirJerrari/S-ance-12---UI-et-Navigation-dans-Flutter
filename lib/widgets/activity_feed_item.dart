import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'status_badge.dart';

class ActivityFeedItem extends StatelessWidget {
  final Activity activity;

  const ActivityFeedItem({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activity.type.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(activity.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(activity.message),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By: ${activity.user}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      StatusBadge(status: activity.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    IconData iconData;
    Color iconColor;

    switch (activity.type) {
      case ActivityType.repositoryAdded:
        iconData = Icons.add_circle;
        iconColor = Colors.blue;
        break;
      case ActivityType.buildStarted:
      case ActivityType.buildCompleted:
        iconData = Icons.build;
        iconColor = Colors.orange;
        break;
      case ActivityType.deploymentStarted:
      case ActivityType.deploymentCompleted:
        iconData = Icons.rocket_launch;
        iconColor = Colors.purple;
        break;
      case ActivityType.serviceStarted:
      case ActivityType.serviceStopped:
      case ActivityType.serviceHealthChanged:
        iconData = Icons.dns;
        iconColor = Colors.teal;
        break;
      case ActivityType.configurationChanged:
        iconData = Icons.settings;
        iconColor = Colors.grey;
        break;
      case ActivityType.userAction:
        iconData = Icons.person;
        iconColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, HH:mm').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
