import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium glassmorphism project card with hover glow, lift, and animated border.
class ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final String url;
  final Color accentColor;
  final VoidCallback onTap;
  final int index;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.url,
    required this.accentColor,
    required this.onTap,
    required this.index,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: 300,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -10.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              // ignore: deprecated_member_use
              color: widget.accentColor.withOpacity(_isHovered ? 0.75 : 0.22),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: widget.accentColor.withOpacity(_isHovered ? 0.28 : 0.05),
                blurRadius: _isHovered ? 45 : 12,
                spreadRadius: _isHovered ? 4 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      // ignore: deprecated_member_use
                      Colors.white.withOpacity(_isHovered ? 0.09 : 0.05),
                      // ignore: deprecated_member_use
                      widget.accentColor.withOpacity(_isHovered ? 0.06 : 0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: icon + live badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: widget.accentColor.withOpacity(_isHovered ? 0.22 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_android_rounded,
                            color: widget.accentColor,
                            size: 22,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: _isHovered ? widget.accentColor.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: widget.accentColor.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'Live Preview →',
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      widget.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gradient divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            widget.accentColor.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tap hint
                    Row(
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: widget.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to launch in 3D frame',
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.25, curve: Curves.easeOutCubic);
  }
}
