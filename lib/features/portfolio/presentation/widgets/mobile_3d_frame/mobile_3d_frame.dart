import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;
// ignore: deprecated_member_use
import 'dart:html' as html;

class Mobile3DFrameWidget extends StatefulWidget {
  final ScrollController scrollController;
  final String? activeProjectUrl;
  final VoidCallback? onCloseProject;

  const Mobile3DFrameWidget({
    super.key,
    required this.scrollController,
    this.activeProjectUrl,
    this.onCloseProject,
  });

  @override
  State<Mobile3DFrameWidget> createState() => _Mobile3DFrameWidgetState();
}

class _Mobile3DFrameWidgetState extends State<Mobile3DFrameWidget> with SingleTickerProviderStateMixin {
  bool _iframeReady = false;
  String _viewId = 'project-iframe-init';
  late final AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Mobile3DFrameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeProjectUrl != oldWidget.activeProjectUrl) {
      if (widget.activeProjectUrl != null) {
        _viewId = 'project-iframe-${DateTime.now().millisecondsSinceEpoch}';
        _registerIframe();
        setState(() => _iframeReady = false);
        Future.delayed(const Duration(milliseconds: 950), () {
          if (mounted && widget.activeProjectUrl != null) {
            setState(() => _iframeReady = true);
          }
        });
      } else {
        setState(() => _iframeReady = false);
      }
    }
  }

  void _registerIframe() {
    if (widget.activeProjectUrl == null) return;
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      return html.IFrameElement()
        ..src = widget.activeProjectUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.activeProjectUrl != null;
    final Size screen = MediaQuery.of(context).size;

    // Phone model intrinsic dimensions (portrait)
    const double phoneW = 340.0;
    const double phoneH = 700.0;

    // ── LANDSCAPE BACKGROUND MODE ─────────────────────────────────────────
    // Make it larger to fill the screen better (1.1 instead of 0.9)
    final double bgScale = (screen.width / phoneH) * 1.1;

    // ── PORTRAIT ACTIVE MODE (right panel) ────────────────────────────────
    final double rightPanelW = screen.width * 0.38;
    final double rightPanelH = screen.height * 0.86;
    final double activeScale = math.min(
      rightPanelW / phoneW,
      rightPanelH / phoneH,
    ) * 0.95;

    // Base orientation
    final String cameraOrbit = '180deg 90deg 100%';

    return Stack(
      children: [
        // ── 3D MODEL ────────────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeInOutCubic,
          // Fix: use only left and width to avoid left/right/width conflict exception
          left: isActive ? screen.width * 0.62 : 0,
          top: 0,
          bottom: 0,
          width: isActive ? rightPanelW : screen.width,
          child: Center(
            child: AnimatedScale(
              scale: isActive ? activeScale : bgScale,
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeInOutCubic,
              child: AnimatedBuilder(
                animation: Listenable.merge([widget.scrollController, _breathingController]),
                builder: (context, child) {
                  final double scrollOffset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
                  
                  // Smooth 3D Rocking based on scroll
                  final double scrollRockAngle = isActive ? 0 : math.sin(scrollOffset * 0.002) * 15 * (math.pi / 180);
                  
                  // Breathing idle animation (floating + subtle wobble)
                  final double breathValue = _breathingController.value;
                  final double breathYOffset = isActive ? 0 : (breathValue - 0.5) * 12.0;
                  final double breathRotation = isActive ? 0 : (breathValue - 0.5) * 2 * (math.pi / 180);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..translate(0.0, breathYOffset, 0.0)
                      ..rotateY(scrollRockAngle + breathRotation),
                    child: child,
                  );
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: isActive ? -math.pi / 2 : 0,
                    end: isActive ? 0 : -math.pi / 2,
                  ),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeInOutCubic,
                  builder: (context, angle, child) {
                    return Transform.rotate(
                      angle: angle,
                      child: child,
                    );
                  },
                  child: SizedBox(
                  width: phoneW,
                  height: phoneH,
                  child: ModelViewer(
                    src: 'assets/iphone_17_pro_max_silver.glb',
                    alt: 'iPhone 3D model',
                    ar: false,
                    autoRotate: false, // Stopped auto-rotate as requested
                    cameraControls: false,
                    disableZoom: true,
                    disablePan: true,
                    environmentImage: 'neutral',
                    exposure: 1.2,
                    cameraOrbit: cameraOrbit,
                    animationCrossfadeDuration: 800,
                  ),
                ),
              ),
            ),
          ),
        ),
        ),

        // ── DARK OVERLAY FOR BACKGROUND TEXT READABILITY ────────────────────
        IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            opacity: isActive ? 0.0 : 0.7, // Dark fade when in background
            duration: const Duration(milliseconds: 850),
            child: Container(
              color: Colors.black, // Dark overlay
            ),
          ),
        ),

        // ── IFRAME OVERLAY ─────────────────────────────────────────────────
        if (isActive)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeInOutCubic,
            right: screen.width * 0.008,
            top: screen.height * 0.07,
            bottom: screen.height * 0.07,
            width: screen.width * 0.355,
            child: AnimatedOpacity(
              opacity: _iframeReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF080818),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.25),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      if (_iframeReady)
                        HtmlElementView(viewType: _viewId),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ── CLOSE BUTTON ───────────────────────────────────────────────────
        if (isActive)
          Positioned(
            top: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _iframeReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: InkWell(
                onTap: widget.onCloseProject,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.65),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
