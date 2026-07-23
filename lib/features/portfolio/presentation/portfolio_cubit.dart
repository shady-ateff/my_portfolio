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

  const PortfolioLoaded({required this.projects});

  @override
  List<Object?> get props => [projects];
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
      emit(PortfolioLoaded(projects: projects));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }
}
