import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/mobile_3d_frame/mobile_3d_frame.dart';
import '../widgets/particle_background.dart';
import '../widgets/animated_skill_chip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../portfolio_cubit.dart';
import '../widgets/project_card.dart';
import '../widgets/add_project_dialog.dart';
import 'package:my_portfolio/l10n/app_localizations.dart' as l10n;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const _cyan = Color(0xFF00F5FF);
  static const _purple = Color(0xFF7B2FFF);
  static const _green = Color(0xFF00E676);
  static const _bg = Color(0xFF0A0A0F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Particle overlay (always visible now since we don't have a background phone)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 600),
                child: const ParticleBackground(),
              ),
            ),
          ),

          // Main scrollable content
          Positioned.fill(
            child: ListView(
              controller: _scrollController,
              children: [
                _buildHeroSection(context),
                _buildAboutSection(context),
                _buildSkillsSection(context),
                _buildProjectsSection(context), // Phone will be inside here
                const SizedBox(height: 60),
                _buildContactSection(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => const AddProjectDialog(),
                );
                if (result != null && context.mounted) {
                  context.read<PortfolioCubit>().addProject(result);
                }
              },
              backgroundColor: _cyan,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context) {
    final localizations = l10n.AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    Widget textContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvailableBadge(),
        const SizedBox(height: 24),

        // Name — gradient
        Text(
          localizations?.appTitle ?? 'Shady Atef',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 48 : 76,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -2,
            height: 1.0,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

        const SizedBox(height: 18),

        // Typewriter subtitle
        SizedBox(
          height: isMobile ? 60 : 36,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: isMobile ? 16 : 19,
              color: const Color(0xFFA0A0B0),
              letterSpacing: 0.3,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  localizations?.heroTitle ??
                      'Flutter Tech Lead & Software Engineer',
                  speed: const Duration(milliseconds: 75),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                TypewriterAnimatedText(
                  'Clean Architecture Specialist',
                  speed: const Duration(milliseconds: 75),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                TypewriterAnimatedText(
                  'Building Scalable Mobile & Web Apps',
                  speed: const Duration(milliseconds: 75),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
              ],
              repeatForever: true,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 50),

        // CTA buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildGlowButton(
              label: localizations?.viewProjects ?? 'View Projects',
              icon: Icons.rocket_launch_rounded,
              color: _cyan,
              onTap: () => _scrollController.animateTo(
                size.height * (isMobile ? 2.5 : 3.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
              ),
            ),
            _buildOutlineButton(
              label: localizations?.contactMe ?? 'Contact Me',
              icon: Icons.mail_outline_rounded,
              color: _purple,
              onTap: () => _scrollController.animateTo(
                size.height * (isMobile ? 4.5 : 5.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.15),
      ],
    );

    return Container(
      constraints: BoxConstraints(minHeight: size.height),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aurora glow blobs behind everything
          // Positioned(
          //   top: -120,
          //   left: -100,
          //   child: _buildAuroraBlob(isMobile ? 300 : 500, _cyan, 0.06),
          // ),
          // Positioned(
          //   top: 100,
          //   right: -150,
          //   child: _buildAuroraBlob(isMobile ? 400 : 600, _purple, 0.07),
          // ),
          // Positioned(
          //   bottom: -80,
          //   left: size.width * 0.3,
          //   child: _buildAuroraBlob(isMobile ? 250 : 400, _green, 0.04),
          // ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 60,
              vertical: isMobile ? 100 : 0,
            ),
            child: isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProfileImage(isMobile: true),
                      const SizedBox(height: 48),
                      textContent,
                      const SizedBox(height: 100), // Space for scroll indicator
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textContent,
                      _buildProfileImage(isMobile: false),
                    ],
                  ),
          ),

          // Scroll indicator
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SCROLL TO EXPLORE',
                    style: TextStyle(
                      color: Color(0xFF50506A),
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _cyan,
                        size: 28,
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .moveY(
                        begin: 0,
                        end: 7,
                        duration: 750.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveY(
                        begin: 7,
                        end: 0,
                        duration: 750.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }

  /// Decorative aurora glow blob for the hero background
  Widget _buildAuroraBlob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            // ignore: deprecated_member_use
            color.withOpacity(opacity),
            // ignore: deprecated_member_use
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // ignore: deprecated_member_use
        border: Border.all(color: _green.withOpacity(0.45)),
        // ignore: deprecated_member_use
        color: _green.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _green,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.7, 1.7),
                duration: 850.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.7, 1.7),
                end: const Offset(1, 1),
                duration: 850.ms,
              ),
          const SizedBox(width: 8),
          const Text(
            'Available for Work',
            style: TextStyle(
              color: _green,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.08);
  }

  Widget _buildProfileImage({bool isMobile = false}) {
    final double outerSize = isMobile ? 240 : 320;
    final double midSize = isMobile ? 230 : 310;
    final double innerSize = isMobile ? 216 : 296;

    return SizedBox(
      width: outerSize,
      height: outerSize * 1.15, // extra height for the top pop-out
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Inner stack for the rings
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: outerSize,
              height: outerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning gradient ring
                  Container(
                        width: outerSize,
                        height: outerSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [_cyan, _purple, _green, _cyan],
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 4000.ms, curve: Curves.linear),

                  // Gap between ring and image
                  Container(
                    width: midSize,
                    height: midSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bg,
                    ),
                  ),

                  // Colored background for the 3D circle
                  Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          // ignore: deprecated_member_use
                          _purple.withOpacity(0.35),
                          // ignore: deprecated_member_use
                          _cyan.withOpacity(0.35),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: _cyan.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile image popping out
          Positioned(
            bottom:
                (outerSize - innerSize) /
                2, // aligns to the bottom of the inner circle
            child: ClipPath(
              clipper: _TopHalfUnclippedClipper(innerSize),
              child: Image.asset(
                'assets/IMG_20260707_154202-remove-bg-io.png',
                width: innerSize * 1.25, // wider than circle for 3D effect
                height:
                    innerSize *
                    1.4, // scales pop-out height for desktop and mobile
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.85, 0.85));
  }

  Widget _buildGlowButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                // ignore: deprecated_member_use
                color.withOpacity(0.85),
                // ignore: deprecated_member_use
                color.withOpacity(0.45),
              ],
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.38),
                blurRadius: 22,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.55),
              width: 1.5,
            ),
            // ignore: deprecated_member_use
            color: color.withOpacity(0.07),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    String eyebrow, {
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _cyan,
            fontSize: 12,
            letterSpacing: 3.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: isMobile ? 32 : 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_cyan, _purple],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 32 : 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── ABOUT ─────────────────────────────────────────────────────────────────
  Widget _buildAboutSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final aboutText = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'I am a Software Engineer and Flutter Tech Lead passionate about building scalable, high-performance applications using Clean Architecture.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: const Color(0xFFCCCCD8),
            height: 1.85,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'With a background in leading technical committees like RoboTech, I specialize in crafting seamless user experiences and robust backends. I love turning complex problems into elegant, efficient solutions.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            color: const Color(0xFF6E6E80),
            height: 1.85,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            'Clean Architecture',
            'TDD',
            'Open Source',
            'Tech Lead',
          ].map(_buildTag).toList(),
        ),
      ],
    );

    final statsCards = Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        _buildStatCard('3+', 'Years\nExperience', _cyan),
        _buildStatCard('15+', 'Projects\nBuilt', _purple),
        _buildStatCard('8+', 'Tech\nSkills', _green),
        _buildStatCard('∞', 'Clean\nCode', const Color(0xFFFFCA28)),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 60 : 90,
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About Me', 'WHO AM I', isMobile: isMobile),
          const SizedBox(height: 56),
          isMobile
              ? Column(
                  children: [aboutText, const SizedBox(height: 48), statsCards],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: aboutText),
                    const SizedBox(width: 60),
                    Expanded(flex: 3, child: statsCards),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: _purple.withOpacity(0.35)),
        // ignore: deprecated_member_use
        color: _purple.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC0A0FF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label, Color color) {
    return Container(
      width: 126,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.22)),
        // ignore: deprecated_member_use
        color: color.withOpacity(0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF606070),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── SKILLS ────────────────────────────────────────────────────────────────
  Widget _buildSkillsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final skills = <(String, IconData, double, Color)>[
      ('Flutter', Icons.phone_android_rounded, 0.95, const Color(0xFF54C5F8)),
      ('Dart', Icons.code_rounded, 0.95, const Color(0xFF54C5F8)),
      ('Clean Arch', Icons.account_tree_rounded, 0.90, _purple),
      ('.NET Core', Icons.storage_rounded, 0.80, const Color(0xFF9B59B6)),
      (
        'Firebase',
        Icons.local_fire_department_rounded,
        0.85,
        const Color(0xFFFFCA28),
      ),
      ('BLoC/Cubit', Icons.widgets_rounded, 0.92, _cyan),
      ('SQLite', Icons.table_chart_rounded, 0.80, _green),
      (
        'UI/UX Design',
        Icons.design_services_rounded,
        0.85,
        const Color(0xFFE91E63),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 60 : 90,
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tech Stack', 'WHAT I USE', isMobile: isMobile),
          const SizedBox(height: 56),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: skills
                .asMap()
                .entries
                .map(
                  (e) => AnimatedSkillChip(
                    label: e.value.$1,
                    icon: e.value.$2,
                    proficiency: e.value.$3,
                    color: e.value.$4,
                    index: e.key,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── PROJECTS ──────────────────────────────────────────────────────────────
  Widget _buildProjectsSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      // Responsive height or dynamic
      padding: EdgeInsets.fromLTRB(
        isMobile ? 24 : 60,
        isMobile ? 30 : 40,
        isMobile ? 24 : 60,
        0,
      ),
      child: BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Projects',
                "WHAT I'VE BUILT",
                isMobile: isMobile,
              ),
              const SizedBox(height: 24),
              Text(
                'Tap any project card to view its live preview or showcase video in the 3D frame',
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF606070),
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),

              if (state is PortfolioLoading)
                const Center(child: CircularProgressIndicator(color: _cyan))
              else if (state is PortfolioError)
                Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (state is PortfolioLoaded)
                _buildProjectsLayout(context, state, isMobile, size)
              else
                const SizedBox(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProjectsLayout(
    BuildContext context,
    PortfolioLoaded state,
    bool isMobile,
    Size size,
  ) {
    if (state.projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects found.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final projectCards = state.projects.asMap().entries.map((entry) {
      final index = entry.key;
      final project = entry.value;
      final isSelected = state.selectedProject?.id == project.id;

      return ProjectCard(
        project: project,
        accentColor: index % 2 == 0
            ? const Color(0xFF00F5FF)
            : const Color(0xFF7B2FFF),
        isSelected: isSelected,
        index: index,
        onTap: () {
          context.read<PortfolioCubit>().selectProject(project);
          if (isMobile) {
            // Optionally scroll to top of section on mobile to see the phone
          }
        },
        onEdit: kDebugMode
            ? () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) =>
                      AddProjectDialog(existingProject: project),
                );
                if (result != null && context.mounted) {
                  context.read<PortfolioCubit>().updateProject(result);
                }
              }
            : null,
        onDelete: kDebugMode
            ? () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => PointerInterceptor(
                    child: AlertDialog(
                      backgroundColor: const Color(0xFF131325),
                      title: const Text('Delete Project?'),
                      content: Text(
                        'Are you sure you want to delete ${project.name}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<PortfolioCubit>().deleteProject(project.id);
                }
              }
            : null,
      );
    }).toList();

    final projectsList = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        int crossAxisCount = availableWidth > 850 ? 2 : 1;
        final double itemWidth =
            (availableWidth - (crossAxisCount - 1) * 24.0) / crossAxisCount;

        return Wrap(
          spacing: 24.0,
          runSpacing: 24.0,
          children: projectCards.map((card) {
            return SizedBox(width: itemWidth, child: card);
          }).toList(),
        );
      },
    );

    final phonePreview = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: isMobile ? Axis.vertical : Axis.horizontal,
          axisAlignment: -1.0,
          child: child,
        ),
      ),
      child: state.selectedProject == null
          ? const SizedBox.shrink()
          : Padding(
              key: const ValueKey('phone_preview'),
              padding: EdgeInsets.only(
                left: isMobile ? 0 : 40,
                bottom: isMobile ? 40 : 0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
                height: isMobile
                    ? 700
                    : (state.selectedProject!.isVideoLandscape
                          ? (MediaQuery.of(context).size.height * 0.65)
                          : 700),
                width: isMobile
                    ? double.infinity
                    : (state.selectedProject!.isVideoLandscape
                          ? (MediaQuery.of(context).size.width * 0.60)
                          : 400),
                child: Mobile3DFrameWidget(
                  scrollController: _scrollController,
                  selectedProject: state.selectedProject,
                ),
              ),
            ),
    );

    if (isMobile) {
      return Column(children: [phonePreview, projectsList]);
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: projectsList),
          phonePreview,
        ],
      );
    }
  }

  // ── CONTACT ───────────────────────────────────────────────────────────────
  Widget _buildContactSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 40 : 70,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // ignore: deprecated_member_use
            _cyan.withOpacity(0.07),
            // ignore: deprecated_member_use
            _purple.withOpacity(0.07),
          ],
        ),
        border: Border.all(
          // ignore: deprecated_member_use
          color: _cyan.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _cyan.withOpacity(0.04),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'GET IN TOUCH',
            style: TextStyle(
              color: _cyan,
              fontSize: 12,
              letterSpacing: 3.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Let's Build Something\nAmazing Together",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Open to new opportunities, collaborations, and exciting projects.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6E6E80),
              fontSize: isMobile ? 15 : 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 50),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(
                Icons.email_outlined,
                'Email',
                'shadyatefbakry@gmail.com',
                _cyan,
                () => launchUrl(
                  Uri.parse(
                    'https://mail.google.com/mail/?view=cm&fs=1&to=shadyatefbakry@gmail.com',
                  ),
                ),
              ),
              _buildSocialButton(
                Icons.code_rounded,
                'GitHub',
                'github.com/shady-ateff',
                _purple,
                () => launchUrl(Uri.parse('https://github.com/shady-ateff')),
              ),
              _buildSocialButton(
                Icons.person_rounded,
                'LinkedIn',
                'linkedin.com/in/shady-atef',
                const Color(0xFF0A66C2),
                () => launchUrl(Uri.parse('https://linkedin.com/in/shadyatef')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    String label,
    String sublabel,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.28)),
            // ignore: deprecated_member_use
            color: color.withOpacity(0.07),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      color: Color(0xFF606070),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHalfUnclippedClipper extends CustomClipper<Path> {
  final double circleSize;
  _TopHalfUnclippedClipper(this.circleSize);

  @override
  Path getClip(Size size) {
    final path = Path();

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - circleSize / 2),
      width: circleSize,
      height: circleSize,
    );

    // Rectangle for the top half (no clipping)
    path.addRect(
      Rect.fromLTRB(
        -1000,
        -1000,
        size.width + 1000,
        size.height - circleSize / 2,
      ),
    );

    // Circle for the bottom half (clipped to circle)
    path.addOval(rect);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
