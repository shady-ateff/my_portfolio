import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 158,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            // ignore: deprecated_member_use
            color: widget.color.withOpacity(_isHovered ? 0.65 : 0.18),
          ),
          // ignore: deprecated_member_use
          color: widget.color.withOpacity(_isHovered ? 0.11 : 0.05),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
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
    )
        .animate(delay: Duration(milliseconds: 200 + widget.index * 70))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}
