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
import '../widgets/section_editors.dart';
import '../../domain/portfolio_data.dart';
import 'package:my_portfolio/l10n/app_localizations.dart' as l10n;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isReorderMode = false;
  
  // Variables for dynamic phone preview alignment
  final GlobalKey _projectsWrapKey = GlobalKey();
  final Map<String, GlobalKey> _projectCardKeys = {};
  double _phoneTopMargin = 0.0;
  bool _isAutoScrolling = false;

  void _recalculatePhoneMargin(String? selectedProjectId) {
    if (selectedProjectId == null || !mounted) return;
    final wrapContext = _projectsWrapKey.currentContext;
    final cardContext = _projectCardKeys[selectedProjectId]?.currentContext;
    if (wrapContext != null && cardContext != null) {
      final wrapBox = wrapContext.findRenderObject() as RenderBox?;
      final cardBox = cardContext.findRenderObject() as RenderBox?;
      if (wrapBox != null && cardBox != null) {
        final offset = cardBox.localToGlobal(Offset.zero, ancestor: wrapBox);
        if ((_phoneTopMargin - offset.dy).abs() > 1.0) {
          setState(() {
            _phoneTopMargin = offset.dy;
          });
          
          // If layout shifted while auto-scrolling, correct the scroll trajectory!
          if (_isAutoScrolling) {
            Scrollable.ensureVisible(
              cardContext,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: 0.15,
            );
          }
        }
      }
    }
  }

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
            child: BlocBuilder<PortfolioCubit, PortfolioState>(
              builder: (context, state) {
                if (state is PortfolioLoaded) {
                  final data = state.portfolioData;
                  return ListView(
                    controller: _scrollController,
                    children: [
                      _buildHeroSection(context, data.hero),
                      _buildAboutSection(context, data.about),
                      _buildSkillsSection(context, data.skills),
                      _buildExperienceSection(context, data.experience),
                      _buildProjectsSection(
                        context,
                      ), // Phone will be inside here
                      const SizedBox(height: 60),
                      _buildContactSection(context, data.contact),
                      const SizedBox(height: 80),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: _cyan),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'reorder',
                  onPressed: () {
                    if (_isReorderMode) {
                      // Turning off -> save to Firebase
                      context.read<PortfolioCubit>().saveReorder();
                    }
                    setState(() {
                      _isReorderMode = !_isReorderMode;
                    });
                  },
                  backgroundColor: _isReorderMode
                      ? Colors.orange
                      : Colors.grey[800],
                  child: Icon(
                    _isReorderMode ? Icons.save : Icons.reorder,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'add',
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
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildEditableWrapper(Widget child, VoidCallback onEdit) {
    if (!kDebugMode) return child;
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.cyan),
            onPressed: onEdit,
          ),
        ),
      ],
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context, HeroSectionData data) {
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
          data.name,
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
              animatedTexts: data.subtitles
                  .map(
                    (subtitle) => TypewriterAnimatedText(
                      subtitle,
                      speed: const Duration(milliseconds: 75),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    ),
                  )
                  .toList(),
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

    return _buildEditableWrapper(
      Center(
        child: Container(
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
                          const SizedBox(
                            height: 100,
                          ), // Space for scroll indicator
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
        ),
      ),
      () async {
        final state = context.read<PortfolioCubit>().state;
        if (state is PortfolioLoaded) {
          final result = await showDialog<HeroSectionData>(
            context: context,
            builder: (context) => EditHeroDialog(data: data),
          );
          if (result != null && context.mounted) {
            final newData = PortfolioData(
              hero: result,
              about: state.portfolioData.about,
              skills: state.portfolioData.skills,
              experience: state.portfolioData.experience,
              contact: state.portfolioData.contact,
            );
            context.read<PortfolioCubit>().updatePortfolioData(newData);
          }
        }
      },
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
  Widget _buildAboutSection(BuildContext context, AboutSectionData data) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final aboutText = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          data.paragraph1,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: const Color(0xFFCCCCD8),
            height: 1.85,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          data.paragraph2,
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
          children: data.tags.map(_buildTag).toList(),
        ),
      ],
    );

    final statsCards = Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: data.stats.map((stat) {
        return _buildStatCard(
          stat.number,
          stat.label.replaceAll('\\n', '\n'),
          Color(int.parse(stat.colorHex)),
        );
      }).toList(),
    );

    return _buildEditableWrapper(
      Container(
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
                    children: [
                      aboutText,
                      const SizedBox(height: 48),
                      statsCards,
                    ],
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
      ),
      () async {
        final state = context.read<PortfolioCubit>().state;
        if (state is PortfolioLoaded) {
          final result = await showDialog<AboutSectionData>(
            context: context,
            builder: (context) => EditAboutDialog(data: data),
          );
          if (result != null && context.mounted) {
            final newData = PortfolioData(
              hero: state.portfolioData.hero,
              about: result,
              skills: state.portfolioData.skills,
              experience: state.portfolioData.experience,
              contact: state.portfolioData.contact,
            );
            context.read<PortfolioCubit>().updatePortfolioData(newData);
          }
        }
      },
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
  Widget _buildSkillsSection(BuildContext context, SkillsSectionData data) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return _buildEditableWrapper(
      Container(
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
              spacing: 60,
              runSpacing: 40,
              alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: data.categories.map((cat) {
                return SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: Color(int.parse(cat.colorHex)),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: isMobile
                            ? WrapAlignment.center
                            : WrapAlignment.start,
                        children: cat.skills
                            .asMap()
                            .entries
                            .map(
                              (e) => AnimatedSkillChip(
                                label: e.value.name,
                                icon: Icons.code, // default icon
                                proficiency: e.value.proficiency,
                                color: Color(int.parse(cat.colorHex)),
                                index: e.key,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      () async {
        final state = context.read<PortfolioCubit>().state;
        if (state is PortfolioLoaded) {
          final result = await showDialog<SkillsSectionData>(
            context: context,
            builder: (context) => EditSkillsDialog(data: data),
          );
          if (result != null && context.mounted) {
            final newData = PortfolioData(
              hero: state.portfolioData.hero,
              about: state.portfolioData.about,
              skills: result,
              experience: state.portfolioData.experience,
              contact: state.portfolioData.contact,
            );
            context.read<PortfolioCubit>().updatePortfolioData(newData);
          }
        }
      },
    );
  }

  // ── EXPERIENCE ────────────────────────────────────────────────────────────
  Widget _buildExperienceSection(
    BuildContext context,
    ExperienceSectionData data,
  ) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return _buildEditableWrapper(
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 60,
          vertical: isMobile ? 40 : 60,
        ),
        child: Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Experience', 'MY JOURNEY', isMobile: isMobile),
            const SizedBox(height: 56),
            ...data.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildExperienceTimeline(
                isMobile: isMobile,
                role: item.role,
                company: item.company,
                duration: item.duration,
                bullets: [
                  item.description,
                ], // Treat description as single bullet for simplicity, or we could split by newline if we want
                isLast: index == data.items.length - 1,
              );
            }),
          ],
        ),
      ),
      () async {
        final state = context.read<PortfolioCubit>().state;
        if (state is PortfolioLoaded) {
          final result = await showDialog<ExperienceSectionData>(
            context: context,
            builder: (context) => EditExperienceDialog(data: data),
          );
          if (result != null && context.mounted) {
            final newData = PortfolioData(
              hero: state.portfolioData.hero,
              about: state.portfolioData.about,
              skills: state.portfolioData.skills,
              experience: result,
              contact: state.portfolioData.contact,
            );
            context.read<PortfolioCubit>().updatePortfolioData(newData);
          }
        }
      },
    );
  }

  Widget _buildExperienceTimeline({
    required bool isMobile,
    required String role,
    required String company,
    required String duration,
    required List<String> bullets,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline graphics
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 30,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _cyan, width: 3),
                    color: _bg,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_cyan, _purple.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$role ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '@ $company',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA0A0B0),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '▹ ',
                            style: TextStyle(color: _cyan, fontSize: 16),
                          ),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

      final key = _projectCardKeys.putIfAbsent(project.id, () => GlobalKey());
      return ProjectCard(
        key: key,
        project: project,
        accentColor: index % 2 == 0
            ? const Color(0xFF00F5FF)
            : const Color(0xFF7B2FFF),
        isSelected: isSelected,
        index: index,
        onTap: () {
          context.read<PortfolioCubit>().selectProject(project);
          
          _isAutoScrolling = true;
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) _isAutoScrolling = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cardContext = _projectCardKeys[project.id]?.currentContext;
            if (cardContext != null) {
              Scrollable.ensureVisible(
                cardContext,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastOutSlowIn,
                alignment: 0.15, // Align slightly below the top of the screen
              );
            }
          });
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

    final double phonePreviewWidth = isMobile
        ? double.infinity
        : (state.selectedProject?.isVideoLandscape == true
              ? (MediaQuery.of(context).size.width * 0.60)
              : 400);

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    height: isMobile
                        ? 700
                        : (state.selectedProject!.isVideoLandscape
                              ? (MediaQuery.of(context).size.height * 0.65)
                              : 700),
                    width: phonePreviewWidth,
                    child: Mobile3DFrameWidget(
                      scrollController: _scrollController,
                      selectedProject: state.selectedProject,
                    ),
                  ),
                  ...state.selectedProject!.sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: phonePreviewWidth,
                        child: _ExpandableListWidget(
                          title: section.title,
                          items: section.items,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );

    final projectsList = LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recalculatePhoneMargin(state.selectedProject?.id);
        });

        final availableWidth = constraints.maxWidth;
        int crossAxisCount = availableWidth > 850 ? 2 : 1;
        final double itemWidth =
            (availableWidth - (crossAxisCount - 1) * 24.0) / crossAxisCount;

        return Wrap(
          spacing: 24.0,
          runSpacing: 24.0,
          children: projectCards.asMap().entries.expand((entry) {
            final index = entry.key;
            final card = entry.value;

            Widget child = SizedBox(width: itemWidth, child: card);

            if (_isReorderMode) {
              child = Stack(
                children: [
                  child,
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        if (index > 0)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 20,
                            ),
                            color: Colors.orange,
                            onPressed: () {
                              context.read<PortfolioCubit>().reorderProjects(
                                index,
                                index - 1,
                              );
                            },
                          ),
                        if (index < projectCards.length - 1)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 20,
                            ),
                            color: Colors.orange,
                            onPressed: () {
                              context.read<PortfolioCubit>().reorderProjects(
                                index,
                                index + 2,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final isSelected = state.selectedProject?.id == state.projects[index].id;
            if (isMobile && isSelected) {
              return [
                child,
                SizedBox(width: double.infinity, child: phonePreview)
              ];
            }

            return [child];
          }).toList(),
        );
      },
    );

    if (isMobile) {
      return projectsList;
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: KeyedSubtree(
              key: _projectsWrapKey,
              child: projectsList,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            margin: EdgeInsets.only(top: _phoneTopMargin),
            child: phonePreview,
          ),
        ],
      );
    }
  }

  // ── CONTACT ───────────────────────────────────────────────────────────────
  Widget _buildContactSection(BuildContext context, ContactSectionData data) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return _buildEditableWrapper(
      Center(
        child: Container(
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
                  if (data.email.isNotEmpty)
                    _buildSocialButton(
                      Icons.email_outlined,
                      'Email',
                      data.email,
                      _cyan,
                      () => launchUrl(
                        Uri.parse(
                          'https://mail.google.com/mail/?view=cm&fs=1&to=${data.email}',
                        ),
                      ),
                    ),
                  if (data.githubUrl.isNotEmpty)
                    _buildSocialButton(
                      Icons.code_rounded,
                      'GitHub',
                      data.githubUrl
                          .replaceAll('https://', '')
                          .replaceAll('http://', ''),
                      _purple,
                      () => launchUrl(Uri.parse(data.githubUrl)),
                    ),
                  if (data.linkedinUrl.isNotEmpty)
                    _buildSocialButton(
                      Icons.person_rounded,
                      'LinkedIn',
                      data.linkedinUrl
                          .replaceAll('https://', '')
                          .replaceAll('http://', ''),
                      const Color(0xFF0A66C2),
                      () => launchUrl(Uri.parse(data.linkedinUrl)),
                    ),
                  if (data.youtubeUrl.isNotEmpty)
                    _buildSocialButton(
                      Icons.play_circle_outline_rounded,
                      'YouTube',
                      data.youtubeUrl
                          .replaceAll('https://', '')
                          .replaceAll('http://', '')
                          .replaceAll('www.', ''),
                      const Color(0xFFFF0000),
                      () => launchUrl(Uri.parse(data.youtubeUrl)),
                    ),
                  if (data.phone.isNotEmpty)
                    _buildSocialButton(
                      Icons.chat_outlined,
                      'WhatsApp',
                      data.phone,
                      const Color(0xFF25D366),
                      () => launchUrl(
                        Uri.parse('https://wa.me/${data.phone.replaceAll(RegExp(r'[^\d+]'), '')}'),
                      ),
                    ),
                  if (data.cvUrl.isNotEmpty)
                    _buildSocialButton(
                      Icons.picture_as_pdf,
                      'Resume',
                      'Download CV',
                      Colors.redAccent,
                      () => launchUrl(Uri.parse(data.cvUrl)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      () async {
        final state = context.read<PortfolioCubit>().state;
        if (state is PortfolioLoaded) {
          final result = await showDialog<ContactSectionData>(
            context: context,
            builder: (context) => EditContactDialog(data: data),
          );
          if (result != null && context.mounted) {
            final newData = PortfolioData(
              hero: state.portfolioData.hero,
              about: state.portfolioData.about,
              skills: state.portfolioData.skills,
              experience: state.portfolioData.experience,
              contact: result,
            );
            context.read<PortfolioCubit>().updatePortfolioData(newData);
          }
        }
      },
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

class _ExpandableListWidget extends StatefulWidget {
  final String title;
  final List<String> items;

  const _ExpandableListWidget({required this.title, required this.items});

  @override
  State<_ExpandableListWidget> createState() => _ExpandableListWidgetState();
}

class _ExpandableListWidgetState extends State<_ExpandableListWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF131325),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF00F5FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF00F5FF),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
