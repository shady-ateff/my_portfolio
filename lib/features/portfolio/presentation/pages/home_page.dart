import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/mobile_3d_frame/mobile_3d_frame.dart';
import '../widgets/particle_background.dart';
import '../widgets/project_card.dart';
import '../widgets/animated_skill_chip.dart';
import 'package:my_portfolio/l10n/app_localizations.dart' as l10n;
import '../portfolio_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  String? _activeProjectUrl;

  void _openProject(String url) => setState(() => _activeProjectUrl = url);
  void _closeProject() => setState(() => _activeProjectUrl = null);

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
    final bool isActive = _activeProjectUrl != null;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 3D Background
          Positioned.fill(
            child: Mobile3DFrameWidget(
              scrollController: _scrollController,
              activeProjectUrl: _activeProjectUrl,
              onCloseProject: _closeProject,
            ),
          ),

          // Particle overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: isActive ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 600),
                child: const ParticleBackground(),
              ),
            ),
          ),

          // Main scrollable content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            left: 0,
            top: 0,
            bottom: 0,
            width: isActive ? screenWidth * 0.62 : screenWidth,
            child: IgnorePointer(
              ignoring: isActive,
              child: AnimatedOpacity(
                opacity: isActive ? 0.15 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    _buildHeroSection(context),
                    _buildAboutSection(context),
                    _buildSkillsSection(context),
                    _buildProjectsSection(context),
                    _buildContactSection(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context) {
    final localizations = l10n.AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvailableBadge(),
                      const SizedBox(height: 24),

                      // Name — gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_cyan, _purple, _cyan],
                          stops: [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          localizations?.appTitle ?? 'Shady Atef',
                          style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.05,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

                      const SizedBox(height: 18),

                      // Typewriter subtitle
                      SizedBox(
                        height: 36,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 19,
                            color: Color(0xFFA0A0B0),
                            letterSpacing: 0.3,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                localizations?.heroTitle ??
                                    'Flutter Tech Lead & Software Engineer',
                                speed: const Duration(milliseconds: 75),
                              ),
                              TypewriterAnimatedText(
                                'Clean Architecture Specialist',
                                speed: const Duration(milliseconds: 75),
                              ),
                              TypewriterAnimatedText(
                                'Building Scalable Mobile & Web Apps',
                                speed: const Duration(milliseconds: 75),
                              ),
                            ],
                            repeatForever: true,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 50),

                      // CTA buttons
                      Row(
                        children: [
                          _buildGlowButton(
                            label: localizations?.viewProjects ?? 'View Projects',
                            icon: Icons.rocket_launch_rounded,
                            color: _cyan,
                            onTap: () => _scrollController.animateTo(
                              size.height * 3.0,
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildOutlineButton(
                            label: localizations?.contactMe ?? 'Contact Me',
                            icon: Icons.mail_outline_rounded,
                            color: _purple,
                            onTap: () => _scrollController.animateTo(
                              size.height * 5.0,
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.15),
                    ],
                  ),
                ),

                // Profile image
                _buildProfileImage(),
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
                  const Icon(Icons.keyboard_arrow_down_rounded,
                          color: _cyan, size: 28)
                      .animate(onPlay: (c) => c.repeat())
                      .moveY(
                          begin: 0,
                          end: 7,
                          duration: 750.ms,
                          curve: Curves.easeInOut)
                      .then()
                      .moveY(
                          begin: 7,
                          end: 0,
                          duration: 750.ms,
                          curve: Curves.easeInOut),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
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
                  duration: 850.ms)
              .then()
              .scale(
                  begin: const Offset(1.7, 1.7),
                  end: const Offset(1, 1),
                  duration: 850.ms),
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

  Widget _buildProfileImage() {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Spinning gradient ring
          Container(
            width: 320,
            height: 320,
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
            width: 310,
            height: 310,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _bg,
            ),
          ),

          // Profile image
          Container(
            width: 296,
            height: 296,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: _cyan.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(
                    'assets/Gemini_Generated_Image_yqeedxyqeedxyqee.png'),
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
            gradient: LinearGradient(colors: [
              // ignore: deprecated_member_use
              color.withOpacity(0.85),
              // ignore: deprecated_member_use
              color.withOpacity(0.45),
            ]),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.38),
                blurRadius: 22,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )),
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
                width: 1.5),
            // ignore: deprecated_member_use
            color: color.withOpacity(0.07),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String eyebrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 40,
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
              style: const TextStyle(
                fontSize: 42,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About Me', 'WHO AM I'),
          const SizedBox(height: 56),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I am a Software Engineer and Flutter Tech Lead passionate about building scalable, high-performance applications using Clean Architecture.',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFCCCCD8),
                          height: 1.85),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'With a background in leading technical committees like RoboTech, I specialize in crafting seamless user experiences and robust backends. I love turning complex problems into elegant, efficient solutions.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6E6E80),
                          height: 1.85),
                    ),
                    const SizedBox(height: 36),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['Clean Architecture', 'TDD', 'Open Source', 'Tech Lead']
                          .map(_buildTag)
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                flex: 3,
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _buildStatCard('3+', 'Years\nExperience', _cyan),
                    _buildStatCard('15+', 'Projects\nBuilt', _purple),
                    _buildStatCard('8+', 'Tech\nSkills', _green),
                    _buildStatCard('∞', 'Clean\nCode', const Color(0xFFFFCA28)),
                  ],
                ),
              ),
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
            color: Color(0xFFC0A0FF), fontSize: 12, fontWeight: FontWeight.w600),
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
          Text(number,
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF606070), height: 1.4)),
        ],
      ),
    );
  }

  // ── SKILLS ────────────────────────────────────────────────────────────────
  Widget _buildSkillsSection(BuildContext context) {
    final skills = <(String, IconData, double, Color)>[
      ('Flutter', Icons.phone_android_rounded, 0.95, const Color(0xFF54C5F8)),
      ('Dart', Icons.code_rounded, 0.95, const Color(0xFF54C5F8)),
      ('Clean Arch', Icons.account_tree_rounded, 0.90, _purple),
      ('.NET Core', Icons.storage_rounded, 0.80, const Color(0xFF9B59B6)),
      ('Firebase', Icons.local_fire_department_rounded, 0.85, const Color(0xFFFFCA28)),
      ('BLoC/Cubit', Icons.widgets_rounded, 0.92, _cyan),
      ('SQLite', Icons.table_chart_rounded, 0.80, _green),
      ('UI/UX Design', Icons.design_services_rounded, 0.85, const Color(0xFFE91E63)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tech Stack', 'WHAT I USE'),
          const SizedBox(height: 56),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: skills
                .asMap()
                .entries
                .map((e) => AnimatedSkillChip(
                      label: e.value.$1,
                      icon: e.value.$2,
                      proficiency: e.value.$3,
                      color: e.value.$4,
                      index: e.key,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── PROJECTS ──────────────────────────────────────────────────────────────
  Widget _buildProjectsSection(BuildContext context) {
    const accentColors = [
      _cyan,
      _purple,
      _green,
      Color(0xFFFF6B6B),
      Color(0xFFFFCA28),
      Color(0xFF26C6DA),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Projects', "WHAT I'VE BUILT"),
          const SizedBox(height: 56),
          BlocBuilder<PortfolioCubit, PortfolioState>(
            builder: (context, state) {
              if (state is PortfolioLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: _cyan));
              } else if (state is PortfolioError) {
                return Center(
                  child: Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                );
              } else if (state is PortfolioLoaded) {
                final projects = state.projects;
                if (projects.isEmpty) {
                  return const Text('No projects found.',
                      style: TextStyle(color: Colors.white54));
                }
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: projects.asMap().entries.map((e) {
                    final p = e.value;
                    return ProjectCard(
                      title: p.name,
                      description: p.description,
                      url: p.liveBuildUrl ?? p.repositoryUrl,
                      accentColor: accentColors[e.key % accentColors.length],
                      onTap: () =>
                          _openProject(p.liveBuildUrl ?? p.repositoryUrl),
                      index: e.key,
                    );
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  // ── CONTACT ───────────────────────────────────────────────────────────────
  Widget _buildContactSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
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
          const Text(
            "Let's Build Something\nAmazing Together",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Open to new opportunities, collaborations, and exciting projects.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6E6E80), fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(Icons.email_outlined, 'Email',
                  'shadyatef.dev@gmail.com', _cyan),
              _buildSocialButton(Icons.code_rounded, 'GitHub',
                  'github.com/shady-atef', _purple),
              _buildSocialButton(Icons.person_rounded, 'LinkedIn',
                  'linkedin.com/in/shady-atef', const Color(0xFF0A66C2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      IconData icon, String label, String sublabel, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(sublabel,
                    style: const TextStyle(
                        color: Color(0xFF606070), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
