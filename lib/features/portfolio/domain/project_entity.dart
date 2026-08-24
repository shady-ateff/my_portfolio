class ProjectSection {
  final String title;
  final List<String> items;

  const ProjectSection({
    required this.title,
    required this.items,
  });

  factory ProjectSection.fromJson(Map<String, dynamic> json) {
    return ProjectSection(
      title: json['title'] ?? '',
      items: List<String>.from(json['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items,
    };
  }
}

class ProjectEntity {
  final String id;
  final String name;
  final String description;
  final int starsCount;
  final String? repositoryUrl;
  final String? liveBuildUrl;
  final List<String> topics;
  final String? language;
  final List<String> packages;
  final List<String> targetPlatforms;
  final String? youtubeVideoId;
  final bool isVideoLandscape;
  final String? googlePlayUrl;
  final String? appStoreUrl;
  final List<ProjectSection> sections;
  final int order;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.starsCount,
    this.repositoryUrl,
    this.liveBuildUrl,
    required this.topics,
    this.language,
    this.packages = const [],
    this.targetPlatforms = const [],
    this.youtubeVideoId,
    this.isVideoLandscape = false,
    this.googlePlayUrl,
    this.appStoreUrl,
    this.sections = const [],
    this.order = 0,
  });

  bool get canExecuteLive => liveBuildUrl != null && liveBuildUrl!.isNotEmpty;
  bool get hasVideo => youtubeVideoId != null && youtubeVideoId!.isNotEmpty;
  bool get hasRepository => repositoryUrl != null && repositoryUrl!.isNotEmpty;
}
