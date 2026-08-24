import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/project_entity.dart';
import '../domain/portfolio_data.dart';
import 'github_projects_repository.dart'; // For the abstract class ProjectsRepository

class FirebaseProjectsRepository implements ProjectsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProjectEntity>> fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      
      final projects = snapshot.docs.map((doc) {
        final data = doc.data();
        List<ProjectSection> parsedSections = [];
        if (data['sections'] != null) {
          parsedSections = (data['sections'] as List<dynamic>)
              .map((s) => ProjectSection.fromJson(Map<String, dynamic>.from(s as Map)))
              .toList();
        } else {
          final oldFeatures = List<String>.from(data['features'] ?? []);
          if (oldFeatures.isNotEmpty) {
            parsedSections.add(ProjectSection(title: '✨ Key Features', items: oldFeatures));
          }
          final oldUsageTips = List<String>.from(data['usageTips'] ?? []);
          if (oldUsageTips.isNotEmpty) {
            parsedSections.add(ProjectSection(title: '💡 Usage Tips', items: oldUsageTips));
          }
        }

        return ProjectEntity(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? 'No description available.',
          starsCount: data['starsCount'] ?? 0,
          repositoryUrl: data['repositoryUrl']?.isNotEmpty == true ? data['repositoryUrl'] : null,
          liveBuildUrl: data['liveBuildUrl'],
          topics: List<String>.from(data['topics'] ?? []),
          language: data['language'],
          packages: List<String>.from(data['packages'] ?? []),
          targetPlatforms: List<String>.from(data['targetPlatforms'] ?? []),
          youtubeVideoId: data['youtubeVideoId'],
          isVideoLandscape: data['isVideoLandscape'] ?? false,
          googlePlayUrl: data['googlePlayUrl'],
          appStoreUrl: data['appStoreUrl'],
          sections: parsedSections,
          order: data['order'] ?? 0,
        );
      }).toList();

      projects.sort((a, b) => a.order.compareTo(b.order));
      return projects;
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
          sections: [
            ProjectSection(
              title: '✨ Key Features',
              items: ['Fully responsive UI', '3D phone frame', 'Firebase integration'],
            ),
            ProjectSection(
              title: '💡 Usage Tips',
              items: ['Scroll to explore the 3D frame', 'Click contact buttons to reach me'],
            ),
          ],
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
      'sections': project.sections.map((s) => s.toJson()).toList(),
      'order': project.order,
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
      'sections': project.sections.map((s) => s.toJson()).toList(),
      'order': project.order,
    });
  }

  @override
  Future<void> reorderProjects(List<ProjectEntity> projects) async {
    final batch = _firestore.batch();
    for (int i = 0; i < projects.length; i++) {
      final docRef = _firestore.collection('projects').doc(projects[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteProject(String id) async {
    await _firestore.collection('projects').doc(id).delete();
  }

  @override
  Future<PortfolioData> fetchPortfolioData() async {
    try {
      final doc = await _firestore.collection('portfolio_sections').doc('main_content').get();
      if (doc.exists && doc.data() != null) {
        return PortfolioData.fromJson(doc.data()!);
      }
      return const PortfolioData(
        hero: HeroSectionData(),
        about: AboutSectionData(),
        skills: SkillsSectionData(),
        experience: ExperienceSectionData(),
        contact: ContactSectionData(),
      );
    } catch (e) {
      return const PortfolioData(
        hero: HeroSectionData(),
        about: AboutSectionData(),
        skills: SkillsSectionData(),
        experience: ExperienceSectionData(),
        contact: ContactSectionData(),
      );
    }
  }

  @override
  Future<void> updatePortfolioData(PortfolioData data) async {
    await _firestore.collection('portfolio_sections').doc('main_content').set(data.toJson(), SetOptions(merge: true));
  }
}
