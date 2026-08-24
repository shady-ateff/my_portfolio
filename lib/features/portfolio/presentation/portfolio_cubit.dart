import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_portfolio/features/portfolio/data/github_projects_repository.dart';
import 'package:my_portfolio/features/portfolio/domain/project_entity.dart';
import 'package:my_portfolio/features/portfolio/domain/portfolio_data.dart';

// State
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<ProjectEntity> projects;
  final ProjectEntity? selectedProject;
  final PortfolioData portfolioData;

  const PortfolioLoaded({
    required this.projects, 
    this.selectedProject,
    required this.portfolioData,
  });

  PortfolioLoaded copyWith({
    List<ProjectEntity>? projects,
    ProjectEntity? selectedProject,
    PortfolioData? portfolioData,
  }) {
    return PortfolioLoaded(
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      portfolioData: portfolioData ?? this.portfolioData,
    );
  }

  @override
  List<Object?> get props => [projects, selectedProject, portfolioData];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PortfolioCubit extends Cubit<PortfolioState> {
  final ProjectsRepository repository;

  PortfolioCubit({required this.repository}) : super(PortfolioInitial());

  Future<void> fetchProjects() async {
    emit(PortfolioLoading());
    try {
      final projects = await repository.fetchProjects();
      final portfolioData = await repository.fetchPortfolioData();
      emit(PortfolioLoaded(
        projects: projects, 
        selectedProject: null,
        portfolioData: portfolioData,
      ));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  void selectProject(ProjectEntity project) {
    if (state is PortfolioLoaded) {
      final currentState = state as PortfolioLoaded;
      if (currentState.selectedProject?.id == project.id) {
        emit(currentState.copyWith(selectedProject: null));
      } else {
        emit(currentState.copyWith(selectedProject: project));
      }
    }
  }

  Future<void> addProject(ProjectEntity project) async {
    try {
      await repository.addProject(project);
      await fetchProjects();
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  Future<void> updateProject(ProjectEntity project) async {
    try {
      await repository.updateProject(project);
      await fetchProjects();
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await repository.deleteProject(id);
      await fetchProjects();
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  void reorderProjects(int oldIndex, int newIndex) {
    if (state is PortfolioLoaded) {
      final loadedState = state as PortfolioLoaded;
      final projects = List<ProjectEntity>.from(loadedState.projects);
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = projects.removeAt(oldIndex);
      projects.insert(newIndex, item);

      // Local update only
      emit(loadedState.copyWith(projects: projects));
    }
  }

  Future<void> saveReorder() async {
    if (state is PortfolioLoaded) {
      final projects = (state as PortfolioLoaded).projects;
      try {
        await repository.reorderProjects(projects);
      } catch (e) {
        // Revert on error
        await fetchProjects();
        emit(PortfolioError(e.toString()));
      }
    }
  }

  Future<void> updatePortfolioData(PortfolioData data) async {
    if (state is PortfolioLoaded) {
      final currentState = state as PortfolioLoaded;
      emit(currentState.copyWith(portfolioData: data));
      try {
        await repository.updatePortfolioData(data);
      } catch (e) {
        // Revert on error
        await fetchProjects();
        emit(PortfolioError(e.toString()));
      }
    }
  }
}
