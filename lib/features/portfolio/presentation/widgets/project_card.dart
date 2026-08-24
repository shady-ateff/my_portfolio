import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/project_entity.dart';

/// Premium glassmorphism project card with hover glow, lift, and animated border.
class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final Color accentColor;
  final VoidCallback onTap;
  final int index;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.accentColor,
    required this.onTap,
    required this.index,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = _isHovered || widget.isSelected;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: 340,
          transform: Matrix4.identity()
            ..setTranslationRaw(0.0, isHighlighted ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.accentColor.withOpacity(isHighlighted ? 0.75 : 0.22),
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(isHighlighted ? 0.28 : 0.05),
                blurRadius: isHighlighted ? 45 : 12,
                spreadRadius: isHighlighted ? 4 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(isHighlighted ? 0.09 : 0.05),
                      widget.accentColor.withOpacity(isHighlighted ? 0.06 : 0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: widget.project.targetPlatforms.map((p) {
                            IconData icon;
                            if (p.toLowerCase() == 'web') icon = Icons.language_rounded;
                            else if (p.toLowerCase() == 'desktop') icon = Icons.desktop_windows_rounded;
                            else icon = Icons.phone_android_rounded;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(icon, color: widget.accentColor, size: 20),
                            );
                          }).toList(),
                        ),
                        Row(
                          children: [
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                color: Colors.white54,
                                hoverColor: widget.accentColor.withOpacity(0.2),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: widget.onEdit,
                              ),
                            if (widget.onEdit != null) const SizedBox(width: 8),
                            if (widget.onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                color: Colors.white54,
                                hoverColor: Colors.redAccent.withOpacity(0.2),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: widget.onDelete,
                              ),
                            if (widget.onDelete != null || widget.onEdit != null) const SizedBox(width: 12),
                            if (widget.project.canExecuteLive || widget.project.hasVideo)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    String? url;
                                    if (widget.project.canExecuteLive) {
                                      url = widget.project.liveBuildUrl;
                                      if (url != null && !url.startsWith('http')) {
                                        url = 'https://$url';
                                      }
                                    } else if (widget.project.hasVideo) {
                                      url = 'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}';
                                    }
                                    if (url != null) {
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 280),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isHighlighted ? widget.accentColor.withOpacity(0.18) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: widget.accentColor.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      widget.project.canExecuteLive ? 'Live Preview →' : 'Watch Video →',
                                      style: TextStyle(
                                        color: widget.accentColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.project.name,
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
                      widget.project.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Packages tags
                    if (widget.project.packages.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.project.packages.map((pkg) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.accentColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            pkg,
                            style: TextStyle(
                              color: widget.accentColor.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                    
                    if (widget.project.packages.isNotEmpty)
                      const SizedBox(height: 20),

                    // Gradient divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
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
                          widget.isSelected ? Icons.check_circle_rounded : Icons.open_in_new_rounded,
                          size: 14,
                          color: widget.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isSelected ? 'Currently Viewing' : 'Tap to preview',
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (widget.project.hasRepository)
                          _buildStoreButton(icon: Icons.code_rounded, text: 'GitHub', url: widget.project.repositoryUrl!),
                        if (widget.project.googlePlayUrl?.isNotEmpty == true)
                          _buildStoreButton(icon: Icons.android_rounded, text: 'Play Store', url: widget.project.googlePlayUrl!),
                        if (widget.project.appStoreUrl?.isNotEmpty == true)
                          _buildStoreButton(icon: Icons.apple_rounded, text: 'App Store', url: widget.project.appStoreUrl!),
                      ],
                    ),
                  ],
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

  Widget _buildStoreButton({required IconData icon, required String text, required String url}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Tooltip(
        message: 'Open in $text',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.accentColor.withOpacity(0.15),
                border: Border.all(color: widget.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: widget.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
