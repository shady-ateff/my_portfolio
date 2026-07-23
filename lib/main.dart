import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:my_portfolio/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/portfolio/presentation/portfolio_cubit.dart';
import 'features/portfolio/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();
  // TODO: Initialize Firebase
  runApp(const PortfolioApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => di.sl<PortfolioCubit>()..fetchProjects(),
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Dashboard')), // Placeholder
      ),
    ),
  ],
);

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shady Atef',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
