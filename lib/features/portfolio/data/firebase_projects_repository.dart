import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/project_entity.dart';
import 'github_projects_repository.dart'; // For the abstract class ProjectsRepository

class FirebaseProjectsRepository implements ProjectsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProjectEntity>> fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').orderBy('createdAt', descending: true).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProjectEntity(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? 'No description available.',
          starsCount: data['starsCount'] ?? 0,
          repositoryUrl: data['repositoryUrl'] ?? '',
          liveBuildUrl: data['liveBuildUrl'],
          topics: List<String>.from(data['topics'] ?? []),
          language: data['language'],
          packages: List<String>.from(data['packages'] ?? []),
          targetPlatforms: List<String>.from(data['targetPlatforms'] ?? []),
          youtubeVideoId: data['youtubeVideoId'],
          isVideoLandscape: data['isVideoLandscape'] ?? false,
          googlePlayUrl: data['googlePlayUrl'],
          appStoreUrl: data['appStoreUrl'],
          usageTips: List<String>.from(data['usageTips'] ?? []),
        );
      }).toList();
    } catch (e) {
      // For development, if Firebase fails (e.g. no internet or rules not set), return some dummy data to test UI
      return [
        ProjectEntity(
          id: 'dummy1',
          name: 'My Portfolio',
          description: 'A beautiful 3D interactive portfolio built with Flutter Web and Firebase.',
          starsCount: 42,
          repositoryUrl: 'https://github.com/shady-ateff',
          topics: ['flutter', 'web', 'portfolio'],
          language: 'Dart',
          packages: ['flutter_animate', 'firebase_core', 'url_launcher'],
          targetPlatforms: ['web', 'mobile', 'desktop'],
          youtubeVideoId: 'dQw4w9WgXcQ', // Dummy video
          usageTips: ['Scroll to explore the 3D frame', 'Click contact buttons to reach me'],
        ),
      ];
    }
  }

  @override
  Future<void> addProject(ProjectEntity project) async {
    await _firestore.collection('projects').add({
      'name': project.name,
      'description': project.description,
      'starsCount': project.starsCount,
      'repositoryUrl': project.repositoryUrl,
      'liveBuildUrl': project.liveBuildUrl,
      'topics': project.topics,
      'language': project.language,
      'packages': project.packages,
      'targetPlatforms': project.targetPlatforms,
      'youtubeVideoId': project.youtubeVideoId,
      'isVideoLandscape': project.isVideoLandscape,
      'googlePlayUrl': project.googlePlayUrl,
      'appStoreUrl': project.appStoreUrl,
      'usageTips': project.usageTips,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    await _firestore.collection('projects').doc(project.id).update({
      'name': project.name,
      'description': project.description,
      'repositoryUrl': project.repositoryUrl,
      'liveBuildUrl': project.liveBuildUrl,
      'packages': project.packages,
      'targetPlatforms': project.targetPlatforms,
      'youtubeVideoId': project.youtubeVideoId,
      'isVideoLandscape': project.isVideoLandscape,
      'googlePlayUrl': project.googlePlayUrl,
      'appStoreUrl': project.appStoreUrl,
      'usageTips': project.usageTips,
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    await _firestore.collection('projects').doc(id).delete();
  }
}
