// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../portfolio_cubit.dart';

class Mobile3DFrameWidget extends StatefulWidget {
  final ScrollController scrollController;
  const Mobile3DFrameWidget({super.key, required this.scrollController});

  @override
  State<Mobile3DFrameWidget> createState() => _Mobile3DFrameWidgetState();
}

class _Mobile3DFrameWidgetState extends State<Mobile3DFrameWidget> {
  static int _counter = 0;
  late final String _viewType;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'phone3d-${_counter++}';
    
    // Listen for scroll events from iframe
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        final data = event.data as Map;
        if (data['type'] == 'scroll') {
          final deltaY = data['deltaY'] as num;
          if (widget.scrollController.hasClients) {
            final current = widget.scrollController.offset;
            final max = widget.scrollController.position.maxScrollExtent;
            final min = widget.scrollController.position.minScrollExtent;
            var target = current + deltaY;
            if (target < min) target = min;
            if (target > max) target = max;
            widget.scrollController.jumpTo(target);
          }
        }
      }
    });
  }

  String _buildHtml(List<dynamic> projects) {
    const accent = ['#00F5FF','#7B2FFF','#00E676','#FF6B6B','#FFCA28','#26C6DA'];

    final cards = projects.asMap().entries.map((e) {
      final i = e.key; final p = e.value;
      final c = accent[i % accent.length];
      final url = (p.liveBuildUrl?.isNotEmpty == true) ? p.liveBuildUrl! : p.repositoryUrl;
      final desc = p.description.length > 90 ? '${p.description.substring(0, 90)}...' : p.description;
      final delay = 2100 + i * 160;
      final isGithub = url.contains('github.com');
      final badgeHtml = isGithub 
          ? '<div class="live-badge" style="border-color:$c;color:$c">CODE</div>' 
          : '<div class="live-badge" style="border-color:$c;color:$c">LIVE</div>';

      return '''
<div class="card" style="--accent:$c; animation-delay:${delay}ms" onclick="openProject('$url', '$isGithub')">
  <div class="card-glow"></div>
  <div class="card-top">
    <div class="card-icon" style="background:color-mix(in srgb,$c 15%,transparent)">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="$c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="3"/><circle cx="12" cy="18" r="0.5" fill="$c"/></svg>
    </div>
    $badgeHtml
  </div>
  <div class="card-title">${p.name}</div>
  <div class="card-desc">$desc</div>
  <div class="card-footer"><span class="open-btn" style="color:$c">Open Preview →</span></div>
</div>''';
    }).join('\n');

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
html,body{width:100%;height:100%;overflow:hidden;background:transparent;font-family:-apple-system,'Inter',sans-serif}
.scene{width:100%;height:100%;display:flex;align-items:center;justify-content:center;perspective:2500px}

/* ── Phone wrapper: Base state is landscape ── */
.pw {
  transform-style:preserve-3d;
  transform:rotateY(0deg) rotateZ(-90deg) scale(var(--s, 1));
  animation:spin 2s cubic-bezier(.23,1,.32,1) both;
}
@keyframes spin {
  0%  {transform:rotateY(-540deg) rotateZ(-90deg) scale(.2);opacity:0}
  40% {opacity:1}
  75% {transform:rotateY(15deg)   rotateZ(-90deg) scale(calc(var(--s,1) * 1.04))}
  90% {transform:rotateY(-6deg)   rotateZ(-90deg) scale(calc(var(--s,1) * 0.98))}
  100%{transform:rotateY(0deg)    rotateZ(-90deg) scale(var(--s,1));opacity:1}
}

/* ── Phone shell: portrait 510×1050 (1.5x resolution for crispness) ── */
.ph{
  position:relative;width:510px;height:1050px;border-radius:72px;
  background:linear-gradient(160deg,#1c1c30 0%,#131325 50%,#0d0d20 100%);
  box-shadow:0 0 0 2px rgba(255,255,255,.10),0 0 0 4.5px rgba(0,0,0,.85),
    inset 0 1px 0 rgba(255,255,255,.13),0 0 120px rgba(0,245,255,.14),
    0 0 240px rgba(123,47,255,.10),60px 105px 210px rgba(0,0,0,.75);
  transform-style:preserve-3d
}
.btn{position:absolute;background:linear-gradient(180deg,#252540,#1a1a30);border-radius:3px}
.bvu{left:-4px;top:210px;width:4px;height:57px;border-radius:3px 0 0 3px}
.bvd{left:-4px;top:288px;width:4px;height:57px;border-radius:3px 0 0 3px}
.bpw{right:-4px;top:255px;width:4px;height:97px;border-radius:0 3px 3px 0}
.isl{position:absolute;top:21px;left:50%;transform:translateX(-50%);width:142px;height:42px;
  background:#050512;border-radius:45px;z-index:10;display:flex;align-items:center;justify-content:center;gap:12px}
.ic{width:15px;height:15px;border-radius:50%;background:radial-gradient(circle at 35% 35%,#1a3a5c,#060c18);border:1px solid rgba(255,255,255,.04)}
.id{width:7px;height:7px;border-radius:50%;background:radial-gradient(circle,#1e3a50,#0a1520)}
.shine{position:absolute;inset:0;border-radius:72px;pointer-events:none;z-index:9;
  background:linear-gradient(135deg,rgba(255,255,255,.07) 0%,transparent 45%,transparent 60%,rgba(255,255,255,.02) 100%)}
.screen{position:absolute;top:19px;left:19px;right:19px;bottom:19px;border-radius:55px;overflow:hidden;background:#08080f}

/* ══════════════════════════════════════════════
   COUNTER-ROTATED LANDSCAPE CONTENT
   Screen = 472×1012. Landscape content = 1012×472.
   transform: translateX(472px) rotate(90deg);
══════════════════════════════════════════════ */
.cl{
  position:absolute;width:1012px;height:472px;
  transform-origin:0 0;
  transform:translateX(472px) rotate(90deg);
  display:flex;flex-direction:column
}
.st{
  display:flex;align-items:center;justify-content:space-between;
  padding:0 30px;height:57px;flex-shrink:0;
  background:linear-gradient(180deg,rgba(8,8,15,1) 0%,rgba(8,8,15,0) 100%);
  position:relative;z-index:2
}
.st-t{color:#fff;font-size:18px;font-weight:700;letter-spacing:.75px}
.st-i{display:flex;gap:7px;align-items:center;transform:scale(1.5);transform-origin:right center}
.sa{flex:1;overflow-y:auto;overflow-x:hidden;padding:18px 18px 27px;-webkit-overflow-scrolling:touch}
.sa::-webkit-scrollbar{width:3px}
.sa::-webkit-scrollbar-thumb{background:rgba(0,245,255,.25);border-radius:3px}
.sl{font-size:13px;font-weight:800;letter-spacing:4px;text-transform:uppercase;
  background:linear-gradient(90deg,#00F5FF,#7B2FFF);-webkit-background-clip:text;
  -webkit-text-fill-color:transparent;background-clip:text;margin-bottom:18px;padding:0 3px}

/* ── Cards ── */
.card{
  position:relative;background:rgba(255,255,255,.04);
  border:1.5px solid color-mix(in srgb,var(--accent) 28%,transparent);
  border-radius:21px;padding:20px;margin-bottom:14px;cursor:pointer;overflow:hidden;
  backdrop-filter:blur(12px);
  animation:slideUp .4s cubic-bezier(.23,1,.32,1) both;
  transition:border-color .2s,background .2s,transform .2s,box-shadow .2s
}
@keyframes slideUp{from{opacity:0;transform:translateY(21px)}to{opacity:1;transform:translateY(0)}}
.card:hover{background:rgba(255,255,255,.08);border-color:var(--accent);transform:translateY(-3px);
  box-shadow:0 9px 36px color-mix(in srgb,var(--accent) 20%,transparent)}
.card:active{transform:scale(.98)}
.card-glow{position:absolute;top:0;left:0;right:0;height:1.5px;
  background:linear-gradient(90deg,transparent,var(--accent),transparent);opacity:.5}
.card-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:13px}
.card-icon{width:48px;height:48px;border-radius:13px;display:flex;align-items:center;justify-content:center}
.live-badge{font-size:12px;font-weight:800;letter-spacing:2.2px;border:1.5px solid;border-radius:30px;padding:3px 12px;opacity:.85}
.card-title{color:#fff;font-size:19px;font-weight:700;margin-bottom:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.card-desc{color:rgba(255,255,255,.45);font-size:15px;line-height:1.6;margin-bottom:13px}
.card-footer{border-top:1px solid rgba(255,255,255,.05);padding-top:10px}
.open-btn{font-size:15px;font-weight:700;letter-spacing:.75px}

/* ── Portrait overlay (after rotation) ── */
.po{display:none;position:absolute;inset:0;z-index:50;flex-direction:column;background:#000}
.po.vis{display:flex;animation:fadeIn .3s ease}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.ob{display:flex;align-items:center;padding:15px 21px;gap:10px;
  background:rgba(0,0,0,.95);border-bottom:1px solid rgba(255,255,255,.06);flex-shrink:0}
.d{width:15px;height:15px;border-radius:50%;cursor:pointer;border:none;transition:filter .15s}
.dc{background:#FF5F57}.dc:hover{filter:brightness(1.3)}
.dm{background:#FEBC2E}.dg{background:#28C840}
.ou{flex:1;color:rgba(255,255,255,.35);font-size:13px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;padding:0 7px}
.pf{flex:1;border:none;width:100%}
</style>
</head>
<body>
<div class="scene">
  <div class="pw" id="pw">
    <div class="ph">
      <div class="btn bvu"></div><div class="btn bvd"></div><div class="btn bpw"></div>
      <div class="isl"><div class="id"></div><div class="ic"></div><div class="id"></div></div>
      <div class="shine"></div>
      <div class="screen">
        <div class="cl" id="cl">
          <div class="st">
            <span class="st-t" id="clk">9:41</span>
            <div class="st-i">
              <svg width="14" height="11" viewBox="0 0 14 11" fill="white"><path d="M7 2C9.4 2 11.6 3 13.2 4.7L14 3.7C12.1 1.4 9.7.3 7 .3S1.9 1.4 0 3.7l.8 1C2.4 3 4.6 2 7 2z"/><path d="M7 5.5C8.7 5.5 10.2 6.2 11.3 7.3l.8-.9C10.7 5 8.9 4.2 7 4.2S3.3 5 1.9 6.4l.8.9C3.8 6.2 5.3 5.5 7 5.5z"/><circle cx="7" cy="10" r="1.2"/></svg>
              <svg width="22" height="11" viewBox="0 0 22 11" fill="none"><rect x=".5" y=".5" width="18" height="10" rx="2.5" stroke="white" stroke-opacity=".5"/><rect x="2" y="2" width="12" height="7" rx="1.5" fill="white"/><path d="M20 3.5v4a2 2 0 000-4z" fill="white" fill-opacity=".4"/></svg>
            </div>
          </div>
          <div class="sa" id="scrollArea">
            <div class="sl">My Projects</div>
            $cards
          </div>
        </div>
        <div class="po" id="po">
          <div class="ob">
            <button class="d dc" onclick="closeProject()"></button>
            <button class="d dm"></button>
            <button class="d dg"></button>
            <span class="ou" id="ou"></span>
          </div>
          <iframe class="pf" id="pf" sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox" allow="fullscreen"></iframe>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
// Scroll forwarder: send wheel events to Flutter parent
window.addEventListener('wheel', function(e) {
  var sa = document.getElementById('scrollArea');
  var isOverCards = sa.contains(e.target);
  
  if (isOverCards) {
    // If hovering over cards, let native scroll handle it unless we are at edges
    var atTop = sa.scrollTop === 0;
    var atBottom = Math.abs(sa.scrollHeight - sa.scrollTop - sa.clientHeight) < 1;
    if ((atTop && e.deltaY < 0) || (atBottom && e.deltaY > 0)) {
      window.parent.postMessage({ type: 'scroll', deltaY: e.deltaY }, '*');
    }
  } else {
    // If hovering over the phone body but NOT the cards, send scroll to parent
    window.parent.postMessage({ type: 'scroll', deltaY: e.deltaY }, '*');
  }
}, { passive: true });

(function tk(){var d=new Date(),el=document.getElementById("clk");
  if(el)el.textContent=d.getHours().toString().padStart(2,"0")+":"+d.getMinutes().toString().padStart(2,"0");
  setTimeout(tk,30000);})();

var pw=document.getElementById("pw");
pw.addEventListener('animationend', function() {
  pw.style.animation = 'none';
});

function fit(){
  var vw=window.innerWidth,vh=window.innerHeight;
  // Phone base size: 510x1050. Landscape visual size: 1050x510
  var sx=(vw*.92)/1050, sy=(vh*.88)/510, s=Math.min(sx,sy);
  pw.style.setProperty("--s",s);
  if(!pw.classList.contains("portrait")){
    pw.style.transform="rotateY(0deg) rotateZ(-90deg) scale("+s+")";
  }
}
fit();window.addEventListener("resize",fit);

function openProject(url, isGithub){
  var vw=window.innerWidth,vh=window.innerHeight;
  var cl=document.getElementById("cl");
  cl.style.opacity="0";cl.style.transition="opacity .2s";
  
  var sx=(vw*.85)/510,sy=(vh*.92)/1050,ps=Math.min(sx,sy);
  
  pw.style.transition="transform .8s cubic-bezier(.23,1,.32,1)";
  pw.style.transform="rotateY(0deg) rotateZ(0deg) scale("+ps+")";
  pw.classList.add("portrait");
  
  setTimeout(function(){
    var po=document.getElementById("po"),pf=document.getElementById("pf"),ou=document.getElementById("ou");
    
    if (isGithub === 'true' || url.includes('github.com')) {
      var fallback = `<html><body style="background:#0d0d20;color:white;font-family:-apple-system,sans-serif;display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;padding:30px;box-sizing:border-box;">
        <svg width="72" height="72" viewBox="0 0 24 24" fill="white" style="margin-bottom:24px;opacity:0.9"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/></svg>
        <h2 style="margin:0 0 12px 0;font-size:26px;letter-spacing:-0.5px;">Source Code Only</h2>
        <p style="color:rgba(255,255,255,0.5);margin:0 0 35px 0;line-height:1.6;font-size:15px;max-width:300px;">GitHub blocks embedding its pages. You can view the repository directly in a new tab.</p>
        <a href="\${url}" target="_blank" style="background:linear-gradient(90deg,#00F5FF,#7B2FFF);color:white;text-decoration:none;padding:16px 32px;border-radius:30px;font-weight:700;font-size:15px;transition:0.2s;box-shadow:0 8px 24px rgba(123,47,255,0.3);">Open in GitHub ↗</a>
      </body></html>`;
      pf.src = 'data:text/html;charset=utf-8,' + encodeURIComponent(fallback);
    } else {
      pf.src = url;
    }
    
    if(ou) ou.textContent=url;
    po.classList.add("vis");
  },700);
}
function closeProject(){
  var vw=window.innerWidth,vh=window.innerHeight;
  var po=document.getElementById("po"),pf=document.getElementById("pf");
  po.classList.remove("vis");pf.src="about:blank";
  
  var sx=(vw*.92)/1050,sy=(vh*.88)/510,ls=Math.min(sx,sy);
  pw.style.transition="transform .8s cubic-bezier(.23,1,.32,1)";
  pw.style.transform="rotateY(0deg) rotateZ(-90deg) scale("+ls+")";
  pw.classList.remove("portrait");
  
  setTimeout(function(){
    var cl=document.getElementById("cl");
    cl.style.opacity="1";cl.style.transition="opacity .3s";
  },600);
}
</script>
</body>
</html>''';
  }

  void _register(List<dynamic> projects) {
    if (_registered) return;
    _registered = true;
    final html5 = _buildHtml(projects);
    final blob = html.Blob([html5], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int id) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF00F5FF), strokeWidth: 2),
                SizedBox(height: 16),
                Text('Loading projects...', style: TextStyle(color: Color(0xFF00F5FF), fontSize: 12, letterSpacing: 1.5)),
              ],
            ),
          );
        }
        if (state is PortfolioError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (state is PortfolioLoaded) {
          _register(state.projects);
          return SizedBox.expand(child: HtmlElementView(viewType: _viewType));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
