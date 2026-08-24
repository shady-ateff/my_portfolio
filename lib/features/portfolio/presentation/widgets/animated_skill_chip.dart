import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated skill chip with icon, label, proficiency bar, and hover glow.
class AnimatedSkillChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final double proficiency; // 0.0 to 1.0
  final Color color;
  final int index;

  const AnimatedSkillChip({
    super.key,
    required this.label,
    required this.icon,
    required this.proficiency,
    required this.color,
    required this.index,
  });

  @override
  State<AnimatedSkillChip> createState() => _AnimatedSkillChipState();
}

class _AnimatedSkillChipState extends State<AnimatedSkillChip> {
  bool _isHovered = false;

  String get _skillIconUrl {
    final name = widget.label.toLowerCase();
    String iconId = '';
    String style = 'ios'; // Outline style

    // Brands
    if (name.contains('flutter')) iconId = 'flutter';
    else if (name.contains('dart')) iconId = 'dart';
    else if (name.contains('firebase')) iconId = 'firebase';
    else if (name.contains('postgres')) iconId = 'postgreesql';
    else if (name.contains('node')) iconId = 'nodejs';
    else if (name.contains('github')) iconId = 'github';
    else if (name.contains('git')) iconId = 'git';
    else if (name.contains('react')) iconId = 'react-native';
    else if (name.contains('java') && !name.contains('javascript')) iconId = 'java-coffee-cup-logo';
    else if (name.contains('python')) iconId = 'python';
    else if (name.contains('docker')) iconId = 'docker';
    else if (name.contains('aws')) iconId = 'amazon-web-services';
    else if (name.contains('figma')) iconId = 'figma';
    else if (name.contains('mongodb')) iconId = 'mongodb';
    else if (name.contains('swift')) iconId = 'swift';
    else if (name.contains('kotlin')) iconId = 'kotlin';
    else if (name.contains('apple')) iconId = 'mac-os';
    else if (name.contains('android')) iconId = 'android-os';
    else if (name.contains('windows')) iconId = 'windows-10';
    else if (name.contains('linux')) iconId = 'linux';
    else if (name.contains('vue')) iconId = 'vue-js';
    else if (name.contains('angular')) iconId = 'angularjs';
    else if (name.contains('js') || name.contains('javascript')) iconId = 'javascript';
    else if (name.contains('css')) iconId = 'css3';
    else if (name.contains('html')) iconId = 'html-5';
    
    // Generics (Clean Architecture, Animations, etc)
    else if (name.contains('clean')) iconId = 'layers'; // layers for architecture
    else if (name.contains('animat')) iconId = 'magic-wand'; // magic wand for animations
    else if (name.contains('state')) iconId = 'flow-chart'; // state management
    else if (name.contains('platform')) iconId = 'bridge'; // platform channels
    else if (name.contains('api')) iconId = 'api-settings'; // API
    else if (name.contains('tdd') || name.contains('test')) iconId = 'test-tube';
    else if (name.contains('agile') || name.contains('scrum')) iconId = 'sync';
    else if (name.contains('ci/cd') || name.contains('pipeline')) iconId = 'services';

    if (iconId.isNotEmpty) {
      // Use ios style for outlined icons
      return 'https://img.icons8.com/$style/96/FFFFFF/$iconId.png';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedSlide(
        offset: Offset(0, _isHovered ? -0.06 : 0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 158,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.65 : 0.18),
            ),
            color: widget.color.withOpacity(_isHovered ? 0.11 : 0.05),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.22),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              if (_skillIconUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _skillIconUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    color: widget.color,
                    errorBuilder: (context, error, stackTrace) => Icon(widget.icon, color: widget.color, size: 26),
                  ),
                )
              else
                Icon(widget.icon, color: widget.color, size: 26),
              const SizedBox(height: 10),

              // Label
              Text(
                widget.label,
                style: TextStyle(
                  // ignore: deprecated_member_use
                  color: _isHovered ? Colors.white : Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Proficiency bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.proficiency),
                  duration: Duration(milliseconds: 900 + widget.index * 80),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        // Track
                        Container(
                          height: 4,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.07),
                        ),
                        // Fill
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color,
                                  // ignore: deprecated_member_use
                                  widget.color.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),

              // Percentage label
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(widget.proficiency * 100).round()}%',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + widget.index * 70))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}
