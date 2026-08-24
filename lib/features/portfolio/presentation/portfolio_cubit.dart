import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_portfolio/features/portfolio/data/github_projects_repository.dart';
import 'package:my_portfolio/features/portfolio/domain/project_entity.dart';

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

  const PortfolioLoaded({required this.projects, this.selectedProject});

  PortfolioLoaded copyWith({
    List<ProjectEntity>? projects,
    ProjectEntity? selectedProject,
  }) {
    return PortfolioLoaded(
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  @override
  List<Object?> get props => [projects, selectedProject];
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
      emit(PortfolioLoaded(projects: projects, selectedProject: null));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  void selectProject(ProjectEntity project) {
    if (state is PortfolioLoaded) {
      final currentState = state as PortfolioLoaded;
      if (currentState.selectedProject?.id == project.id) {
        emit(PortfolioLoaded(projects: currentState.projects, selectedProject: null));
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
}
