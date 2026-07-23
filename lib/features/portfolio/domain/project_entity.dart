class ProjectEntity {
  final String id;
  final String name;
  final String description;
  final int starsCount;
  final String repositoryUrl;
  final String? liveBuildUrl;
  final List<String> topics;
  final String? language;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.starsCount,
    required this.repositoryUrl,
    this.liveBuildUrl,
    required this.topics,
    this.language,
  });

  bool get canExecuteLive => liveBuildUrl != null && liveBuildUrl!.isNotEmpty;
}
