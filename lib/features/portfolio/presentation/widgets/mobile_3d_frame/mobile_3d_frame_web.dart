import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:ui_web' as ui_web;
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:my_portfolio/features/portfolio/domain/project_entity.dart';

class Mobile3DFrameWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ProjectEntity? selectedProject;

  const Mobile3DFrameWidget({
    super.key,
    required this.scrollController,
    this.selectedProject,
  });

  @override
  State<Mobile3DFrameWidget> createState() => _Mobile3DFrameWidgetState();
}

class _Mobile3DFrameWidgetState extends State<Mobile3DFrameWidget> {
  static int _counter = 0;
  late final String _viewType;
  late html.IFrameElement _iframe;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'phone3d-preview-${_counter++}';

    _iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    final isLandscape = widget.selectedProject?.isVideoLandscape == true;
    final innerContent = _getInnerContent(widget.selectedProject);
    _iframe.srcdoc = _buildHtml(innerContent, isLandscape);
    _isInitialized = true;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int id) => _iframe,
    );
  }

  @override
  void didUpdateWidget(covariant Mobile3DFrameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProject != oldWidget.selectedProject) {
      _updateHtml();
    }
  }

  void _updateHtml() {
    final isLandscape = widget.selectedProject?.isVideoLandscape == true;
    final innerContent = _getInnerContent(widget.selectedProject);

    if (_isInitialized) {
      final message = jsonEncode({
        'type': 'update',
        'isLandscape': isLandscape,
        'innerContent': innerContent,
      });
      _iframe.contentWindow?.postMessage(message, '*');
    }
  }

  String _getInnerContent(ProjectEntity? project) {
    String innerContent = '';

    if (project == null) {
      innerContent = '''
        <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:rgba(255,255,255,0.4); text-align:center; padding:20px;">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:20px;opacity:0.5"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg>
          <h3 style="font-size:18px; font-weight:600; margin-bottom:8px; color:rgba(255,255,255,0.7)">No Project Selected</h3>
          <p style="font-size:14px; line-height:1.5;">Select a project from the list to preview it here.</p>
        </div>
      ''';
    } else {
      if (project.hasVideo) {
        String vId = project.youtubeVideoId!;
        if (vId.length > 11) {
          final RegExp regExp = RegExp(
            r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=|shorts\/)([^#\&\?]*).*',
          );
          final match = regExp.firstMatch(vId);
          if (match != null && match.groupCount >= 2) {
            vId = match.group(2)!;
          }
        }

        innerContent =
            '''
          <iframe width="100%" height="100%" src="https://www.youtube.com/embed/$vId?autoplay=1&mute=1&rel=0&modestbranding=1&playsinline=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen referrerpolicy="strict-origin-when-cross-origin" style="border-radius:35px; border:none; width: 100%; height: 100%; background: #000;"></iframe>
        ''';
      } else if (project.canExecuteLive) {
        String url = project.liveBuildUrl!;
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }

        if (url.contains('github.com')) {
          innerContent =
              '''
            <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:white; text-align:center; padding:20px; background:#0d0d20;">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="white" style="margin-bottom:16px;opacity:0.9"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/></svg>
              <h3 style="margin-bottom:8px;">Source Code Only</h3>
              <p style="font-size:13px; color:rgba(255,255,255,0.6); margin-bottom:20px;">GitHub pages cannot be embedded.</p>
              <a href="${url}" target="_blank" style="padding:10px 20px; background:#00F5FF; color:#000; text-decoration:none; border-radius:20px; font-weight:bold; font-size:14px;">Open in GitHub</a>
            </div>
          ''';
        } else {
          innerContent =
              '<iframe width="100%" height="100%" src="$url" frameborder="0" style="border-radius:35px; background:white;"></iframe>';
        }
      } else {
        innerContent = '''
          <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:rgba(255,255,255,0.4); text-align:center; padding:20px;">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom:16px;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            <p>No preview available for this project.</p>
          </div>
        ''';
      }
    }

    return innerContent;
  }

  String _buildHtml(String innerContent, bool isLandscape) {
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
html,body{width:100%;height:100%;overflow:hidden;background:transparent;font-family:-apple-system,'Inter',sans-serif}
.scene{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}

.pw {
  animation:float 6s ease-in-out infinite;
}
@keyframes float {
  0% {transform: translateY(0px);}
  50% {transform: translateY(-15px);}
  100% {transform: translateY(0px);}
}
.pw.landscape {
}
@keyframes float-landscape {
  0% {transform: translateY(0px);}
  50% {transform: translateY(-15px);}
  100% {transform: translateY(0px);}
}
.pw.landscape {
  animation: float-landscape 6s ease-in-out infinite;
}

/* Phone shell */
.ph{
  position:relative;width:340px;height:700px;border-radius:45px;
  background:linear-gradient(160deg,#1c1c30 0%,#131325 50%,#0d0d20 100%);
  box-shadow:0 0 0 2px rgba(255,255,255,.10),0 0 0 4.5px rgba(0,0,0,.85),
    inset 0 1px 0 rgba(255,255,255,.13),0 0 40px rgba(0,245,255,.10),
    0 0 60px rgba(123,47,255,.08), 10px 20px 40px rgba(0,0,0,.5);
  transform: rotateZ(0deg);
  transition: transform 0.6s cubic-bezier(0.4, 0.0, 0.2, 1);
}
.ph.landscape {
  transform: rotateZ(-90deg);
}

.btn{position:absolute;background:linear-gradient(180deg,#252540,#1a1a30);border-radius:3px;}
.bvu{left:-3px;top:140px;width:3px;height:38px;border-radius:3px 0 0 3px}
.bvd{left:-3px;top:192px;width:3px;height:38px;border-radius:3px 0 0 3px}
.bpw{right:-3px;top:170px;width:3px;height:64px;border-radius:0 3px 3px 0}

.isl{position:absolute;top:14px;left:50%;transform:translateX(-50%);width:95px;height:28px;
  background:#050512;border-radius:45px;z-index:20;display:flex;align-items:center;justify-content:center;gap:8px;}

.ic{width:10px;height:10px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#1a3a5c,#060c18);border:1px solid rgba(255,255,255,.04)}
.id{width:4px;height:4px;border-radius:50%;background:radial-gradient(circle,#1e3a50,#0a1520)}
.shine{position:absolute;inset:0;border-radius:45px;pointer-events:none;z-index:19;
  background:linear-gradient(135deg,rgba(255,255,255,.07) 0%,transparent 45%,transparent 60%,rgba(255,255,255,.02) 100%)}
.screen{position:absolute;top:12px;left:12px;right:12px;bottom:12px;border-radius:35px;overflow:hidden;background:#08080f;}

.screen-content {
  width: 100%; height: 100%;
  position: absolute; top: 50%; left: 50%;
  transform: translate(-50%, -50%) rotateZ(0deg);
  transition: all 0.6s cubic-bezier(0.4, 0.0, 0.2, 1);
}
.ph.landscape .screen-content {
  width: 676px; height: 316px;
  transform: translate(-50%, -50%) rotateZ(90deg);
}
</style>
</head>
<body>
<div class="scene">
  <div id="scale-wrapper" style="display:flex; justify-content:center; align-items:center; width:100%; height:100%; transform-origin:center; transition: transform 0.6s cubic-bezier(0.4, 0.0, 0.2, 1);">
    <div class="pw${isLandscape ? ' landscape' : ''}" id="pw">
      <div class="ph${isLandscape ? ' landscape' : ''}" id="ph">
        <div class="btn bvu"></div><div class="btn bvd"></div><div class="btn bpw"></div>
        <div class="isl"><div class="id"></div><div class="ic"></div><div class="id"></div></div>
        <div class="shine"></div>
        <div class="screen" id="screen">
          <div class="screen-content" id="screen-content">
            $innerContent
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
function updateScale() {
  var pw = document.getElementById('pw');
  if (!pw) return;
  var isLandscape = pw.classList.contains('landscape');
  
  // Minimal padding to eliminate empty spaces
  var baseWidth = isLandscape ? 730 : 370;
  var baseHeight = isLandscape ? 370 : 730;
  
  var scaleX = window.innerWidth / baseWidth;
  var scaleY = window.innerHeight / baseHeight;
  var scale = Math.min(scaleX, scaleY);
  
  document.getElementById('scale-wrapper').style.transform = 'scale(' + scale + ')';
}

window.addEventListener('resize', updateScale);
// Initial scale
updateScale();

window.addEventListener('message', function(event) {
  try {
    var data = JSON.parse(event.data);
    if (data.type === 'update') {
      var pw = document.getElementById('pw');
      var ph = document.getElementById('ph');
      var screenContent = document.getElementById('screen-content');
      
      if (data.isLandscape) {
        pw.classList.add('landscape');
        ph.classList.add('landscape');
      } else {
        pw.classList.remove('landscape');
        ph.classList.remove('landscape');
      }
      
      screenContent.innerHTML = data.innerContent;
      updateScale();
    }
  } catch (e) {}
});
</script>
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: HtmlElementView(viewType: _viewType),
        ),
        if (widget.selectedProject?.hasVideo == true)
          Positioned.fill(
            child: PointerInterceptor(
              intercepting: true,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}
