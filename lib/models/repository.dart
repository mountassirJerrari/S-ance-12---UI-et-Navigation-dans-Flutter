class Repository {
  final String id;
  final String name;
  final String owner;
  final String url;
  final String branch;
  final DateTime lastCommitDate;
  final String lastCommitMessage;
  final String lastCommitAuthor;
  final RepositoryStatus status;
  final List<String> environments;
  final bool hasDockerComposeFile;

  Repository({
    required this.id,
    required this.name,
    required this.owner,
    required this.url,
    required this.branch,
    required this.lastCommitDate,
    required this.lastCommitMessage,
    required this.lastCommitAuthor,
    required this.status,
    required this.environments,
    required this.hasDockerComposeFile,
  });
}

enum RepositoryStatus {
  idle,
  building,
  testing,
  deploying,
  deployed,
  failed,
}

extension RepositoryStatusExtension on RepositoryStatus {
  String get name {
    switch (this) {
      case RepositoryStatus.idle:
        return 'Idle';
      case RepositoryStatus.building:
        return 'Building';
      case RepositoryStatus.testing:
        return 'Testing';
      case RepositoryStatus.deploying:
        return 'Deploying';
      case RepositoryStatus.deployed:
        return 'Deployed';
      case RepositoryStatus.failed:
        return 'Failed';
    }
  }
}
