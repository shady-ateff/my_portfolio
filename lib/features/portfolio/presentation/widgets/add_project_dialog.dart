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
  String? _repositoryUrl;
  String? _liveBuildUrl;
  String? _youtubeVideoId;
  bool _isVideoLandscape = false;
  String? _googlePlayUrl;
  String? _appStoreUrl;
  late String _packagesStr;
  late String _targetPlatformsStr;
  final List<_SectionData> _sections = [];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProject;
    _name = p?.name ?? '';
    _description = p?.description ?? '';
    _repositoryUrl = p?.repositoryUrl;
    _liveBuildUrl = p?.liveBuildUrl;
    _youtubeVideoId = p?.youtubeVideoId;
    _isVideoLandscape = p?.isVideoLandscape ?? false;
    _googlePlayUrl = p?.googlePlayUrl;
    _appStoreUrl = p?.appStoreUrl;
    _packagesStr = p?.packages.join(', ') ?? '';
    _targetPlatformsStr = p?.targetPlatforms.join(', ') ?? '';
    _targetPlatformsStr = p?.targetPlatforms.join(', ') ?? '';
    
    if (p != null && p.sections.isNotEmpty) {
      _sections.addAll(
        p.sections.map((s) => _SectionData(s.title, s.items.join(', '))),
      );
    } else {
      // Default sections
      _sections.add(_SectionData('✨ Key Features', ''));
      _sections.add(_SectionData('💡 Usage Tips', ''));
    }
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
                  decoration: const InputDecoration(labelText: 'Repository URL (Optional - leave blank if private)'),
                  onSaved: (v) => _repositoryUrl = v?.isNotEmpty == true ? v : null,
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
                const SizedBox(height: 16),
                const Text('Custom Sections', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ..._sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return Card(
                    color: const Color(0xFF1C1C30),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: section.title,
                                  decoration: const InputDecoration(labelText: 'Section Title'),
                                  onChanged: (v) => section.title = v,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => _sections.removeAt(index));
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: section.itemsStr,
                            decoration: const InputDecoration(labelText: 'Items (comma separated)'),
                            onChanged: (v) => section.itemsStr = v,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _sections.add(_SectionData('', '')));
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF00F5FF)),
                  label: const Text('Add Section', style: TextStyle(color: Color(0xFF00F5FF))),
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
                repositoryUrl: _repositoryUrl?.isNotEmpty == true ? _repositoryUrl : null,
                liveBuildUrl: _liveBuildUrl?.isNotEmpty == true ? _liveBuildUrl : null,
                youtubeVideoId: _youtubeVideoId?.isNotEmpty == true ? _youtubeVideoId : null,
                isVideoLandscape: _isVideoLandscape,
                googlePlayUrl: _googlePlayUrl?.isNotEmpty == true ? _googlePlayUrl : null,
                appStoreUrl: _appStoreUrl?.isNotEmpty == true ? _appStoreUrl : null,
                packages: _packagesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                targetPlatforms: _targetPlatformsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                sections: _sections
                    .where((s) => s.title.trim().isNotEmpty && s.itemsStr.trim().isNotEmpty)
                    .map((s) => ProjectSection(
                          title: s.title.trim(),
                          items: s.itemsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                        ))
                    .toList(),
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

class _SectionData {
  String title;
  String itemsStr;
  _SectionData(this.title, this.itemsStr);
}
