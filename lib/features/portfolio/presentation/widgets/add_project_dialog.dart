import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../domain/project_entity.dart';

class AddProjectDialog extends StatefulWidget {
  final ProjectEntity? existingProject;

  const AddProjectDialog({super.key, this.existingProject});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _description;
  late String _repositoryUrl;
  String? _liveBuildUrl;
  String? _youtubeVideoId;
  bool _isVideoLandscape = false;
  String? _googlePlayUrl;
  String? _appStoreUrl;
  late String _packagesStr;
  late String _targetPlatformsStr;
  late String _usageTipsStr;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProject;
    _name = p?.name ?? '';
    _description = p?.description ?? '';
    _repositoryUrl = p?.repositoryUrl ?? '';
    _liveBuildUrl = p?.liveBuildUrl;
    _youtubeVideoId = p?.youtubeVideoId;
    _isVideoLandscape = p?.isVideoLandscape ?? false;
    _googlePlayUrl = p?.googlePlayUrl;
    _appStoreUrl = p?.appStoreUrl;
    _packagesStr = p?.packages.join(', ') ?? '';
    _targetPlatformsStr = p?.targetPlatforms.join(', ') ?? '';
    _usageTipsStr = p?.usageTips.join(', ') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;
    return PointerInterceptor(
      child: AlertDialog(
        title: Text(isEditing ? 'Edit Project' : 'Add New Project'),
        backgroundColor: const Color(0xFF131325),
        content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _name = v!,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _description = v!,
                ),
                TextFormField(
                  initialValue: _repositoryUrl,
                  decoration: const InputDecoration(labelText: 'Repository URL'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _repositoryUrl = v!,
                ),
                TextFormField(
                  initialValue: _liveBuildUrl,
                  decoration: const InputDecoration(labelText: 'Live Build URL (Optional)'),
                  onSaved: (v) => _liveBuildUrl = v,
                ),
                TextFormField(
                  initialValue: _youtubeVideoId,
                  decoration: const InputDecoration(labelText: 'YouTube Video Link or ID (Optional)'),
                  onSaved: (v) => _youtubeVideoId = v,
                ),
                SwitchListTile(
                  title: const Text('Is Video Landscape?', style: TextStyle(color: Colors.white70)),
                  value: _isVideoLandscape,
                  onChanged: (v) => setState(() => _isVideoLandscape = v),
                  activeColor: const Color(0xFF00F5FF),
                  contentPadding: EdgeInsets.zero,
                ),
                TextFormField(
                  initialValue: _googlePlayUrl,
                  decoration: const InputDecoration(labelText: 'Google Play URL (Optional)'),
                  onSaved: (v) => _googlePlayUrl = v,
                ),
                TextFormField(
                  initialValue: _appStoreUrl,
                  decoration: const InputDecoration(labelText: 'App Store URL (Optional)'),
                  onSaved: (v) => _appStoreUrl = v,
                ),
                TextFormField(
                  initialValue: _packagesStr,
                  decoration: const InputDecoration(labelText: 'Packages (comma separated)'),
                  onSaved: (v) => _packagesStr = v ?? '',
                ),
                TextFormField(
                  initialValue: _targetPlatformsStr,
                  decoration: const InputDecoration(labelText: 'Target Platforms (comma separated)'),
                  onSaved: (v) => _targetPlatformsStr = v ?? '',
                ),
                TextFormField(
                  initialValue: _usageTipsStr,
                  decoration: const InputDecoration(labelText: 'Usage Tips (comma separated)'),
                  onSaved: (v) => _usageTipsStr = v ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5FF)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              
              final project = ProjectEntity(
                id: widget.existingProject?.id ?? '',
                name: _name,
                description: _description,
                starsCount: widget.existingProject?.starsCount ?? 0,
                repositoryUrl: _repositoryUrl,
                liveBuildUrl: _liveBuildUrl?.isNotEmpty == true ? _liveBuildUrl : null,
                youtubeVideoId: _youtubeVideoId?.isNotEmpty == true ? _youtubeVideoId : null,
                isVideoLandscape: _isVideoLandscape,
                googlePlayUrl: _googlePlayUrl?.isNotEmpty == true ? _googlePlayUrl : null,
                appStoreUrl: _appStoreUrl?.isNotEmpty == true ? _appStoreUrl : null,
                packages: _packagesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                targetPlatforms: _targetPlatformsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                usageTips: _usageTipsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                topics: widget.existingProject?.topics ?? [],
              );
              
              Navigator.pop(context, project);
            }
          },
          child: Text(isEditing ? 'Save Changes' : 'Save Project', style: const TextStyle(color: Colors.black)),
        ),
      ],
    ),
    );
  }
}
