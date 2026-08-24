class ProjectEntity {
  final String id;
  final String name;
  final String description;
  final int starsCount;
  final String repositoryUrl;
  final String? liveBuildUrl;
  final List<String> topics;
  final String? language;
  final List<String> packages;
  final List<String> targetPlatforms;
  final String? youtubeVideoId;
  final bool isVideoLandscape;
  final String? googlePlayUrl;
  final String? appStoreUrl;
  final List<String> usageTips;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.starsCount,
    required this.repositoryUrl,
    this.liveBuildUrl,
    required this.topics,
    this.language,
    this.packages = const [],
    this.targetPlatforms = const [],
    this.youtubeVideoId,
    this.isVideoLandscape = false,
    this.googlePlayUrl,
    this.appStoreUrl,
    this.usageTips = const [],
  });

  bool get canExecuteLive => liveBuildUrl != null && liveBuildUrl!.isNotEmpty;
  bool get hasVideo => youtubeVideoId != null && youtubeVideoId!.isNotEmpty;
}
