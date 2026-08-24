import 'package:get_it/get_it.dart';
import '../../features/portfolio/data/github_projects_repository.dart';
import '../../features/portfolio/data/firebase_projects_repository.dart';
import '../../features/portfolio/presentation/portfolio_cubit.dart';

final sl = GetIt.instance;

void init() {
  // Repository
  sl.registerLazySingleton<ProjectsRepository>(() => FirebaseProjectsRepository());

  // Cubit
  sl.registerFactory(() => PortfolioCubit(repository: sl()));
}
