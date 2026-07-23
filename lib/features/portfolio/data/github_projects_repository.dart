import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/project_entity.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> fetchProjects();
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
          // For now, if the project is "sapos" or "CareSync", let's mock a liveUrl for testing the iframe
          liveBuildUrl: _getMockLiveUrl(json['name']),
        );
      }).where((p) => p.topics.contains('portfolio-project') || p.name.toLowerCase() == 'sapos' || p.name.toLowerCase() == 'taskati').toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  String? _getMockLiveUrl(String name) {
    // dart.dev and flutter.dev block iframes. Using example.com for testing iframe rendering.
    if (name.toLowerCase().contains('sapos')) return 'https://example.com';
    if (name.toLowerCase().contains('taskati')) return 'https://example.com';
    return null;
  }
}
