import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/repository_service.dart';
import '../widgets/widgets.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repositoryService = Provider.of<RepositoryService>(context);
    final repositories = repositoryService.repositories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new repository
              _showAddRepositoryDialog(context);
            },
          ),
        ],
      ),
      body: repositories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: repositories.length,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new repository
          _showAddRepositoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRepositoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Repository'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Repository URL',
                  hintText: 'https://github.com/username/repo',
                ),
                onChanged: (value) {
                  // Update repository URL
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  hintText: 'main',
                ),
                onChanged: (value) {
                  // Update branch
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Build Trigger',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'push',
                    child: Text('On Push'),
                  ),
                  DropdownMenuItem(
                    value: 'manual',
                    child: Text('Manual'),
                  ),
                  DropdownMenuItem(
                    value: 'scheduled',
                    child: Text('Scheduled'),
                  ),
                ],
                onChanged: (value) {
                  // Update build trigger
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add repository
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Repository added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
