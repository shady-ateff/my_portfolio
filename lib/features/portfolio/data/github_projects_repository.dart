import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/project_entity.dart';
import '../domain/portfolio_data.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> fetchProjects();
  Future<void> addProject(ProjectEntity project);
  Future<void> updateProject(ProjectEntity project);
  Future<void> deleteProject(String id);
  Future<void> reorderProjects(List<ProjectEntity> projects);
  Future<PortfolioData> fetchPortfolioData();
  Future<void> updatePortfolioData(PortfolioData data);
}

class GithubProjectsRepository implements ProjectsRepository {
  final String username = 'shady-ateff';

  @override
  Future<List<ProjectEntity>> fetchProjects() async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username/repos?sort=updated&per_page=100'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // Filter out forks if needed, and map to entities
      return data.map((json) {
        return ProjectEntity(
          id: json['id'].toString(),
          name: json['name'],
          description: json['description'] ?? 'No description available.',
          starsCount: json['stargazers_count'] ?? 0,
          repositoryUrl: json['html_url'],
          topics: List<String>.from(json['topics'] ?? []),
          language: json['language'],
          // Use GitHub's homepage field as the live url (if the user provided one)
          liveBuildUrl: _parseHomepage(json['homepage']),
        );
      }).take(10).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  String? _parseHomepage(dynamic homepage) {
    if (homepage == null) return null;
    final str = homepage.toString().trim();
    if (str.isEmpty) return null;
    if (!str.startsWith('http')) return 'https://$str';
  }

  @override
  Future<void> addProject(ProjectEntity project) async {
    throw UnimplementedError('Cannot add project to GitHub repository');
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    throw UnimplementedError('Cannot update project in GitHub repository');
  }

  @override
  Future<void> deleteProject(String id) async {
    throw UnimplementedError('Cannot delete project from GitHub repository');
  }

  @override
  Future<void> reorderProjects(List<ProjectEntity> projects) async {}

  @override
  Future<PortfolioData> fetchPortfolioData() async {
    return const PortfolioData(
      hero: HeroSectionData(),
      about: AboutSectionData(),
      skills: SkillsSectionData(),
      experience: ExperienceSectionData(),
      contact: ContactSectionData(),
    );
  }

  @override
  Future<void> updatePortfolioData(PortfolioData data) async {}
}
