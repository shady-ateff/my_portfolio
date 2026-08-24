import 'package:flutter/material.dart';
import 'package:my_portfolio/features/portfolio/domain/project_entity.dart';

class Mobile3DFrameWidget extends StatelessWidget {
  final ScrollController scrollController;
  final ProjectEntity? selectedProject;

  const Mobile3DFrameWidget({
    super.key,
    required this.scrollController,
    this.selectedProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 700,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D20),
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.web, size: 60, color: Color(0xFF00F5FF)),
              const SizedBox(height: 20),
              Text(
                selectedProject != null ? selectedProject!.name : 'No Project Selected',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '3D Preview is only available on Web.\nThis is a mobile fallback to let you manage your projects.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
