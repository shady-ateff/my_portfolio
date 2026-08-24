import 'package:flutter/material.dart';
import '../../domain/portfolio_data.dart';

class EditHeroDialog extends StatefulWidget {
  final HeroSectionData data;

  const EditHeroDialog({super.key, required this.data});

  @override
  State<EditHeroDialog> createState() => _EditHeroDialogState();
}

class _EditHeroDialogState extends State<EditHeroDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _subtitlesStr;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _name = widget.data.name;
    _subtitlesStr = widget.data.subtitles.join('\n');
    _isAvailable = widget.data.isAvailableForWork;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF131325),
      title: const Text('Edit Hero Section'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (v) => _name = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _subtitlesStr,
                  decoration: const InputDecoration(labelText: 'Subtitles (one per line)'),
                  maxLines: 4,
                  onSaved: (v) => _subtitlesStr = v ?? '',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Available for Work Badge'),
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState?.save();
            final updated = HeroSectionData(
              name: _name,
              subtitles: _subtitlesStr.split('\n').where((e) => e.trim().isNotEmpty).toList(),
              isAvailableForWork: _isAvailable,
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditAboutDialog extends StatefulWidget {
  final AboutSectionData data;

  const EditAboutDialog({super.key, required this.data});

  @override
  State<EditAboutDialog> createState() => _EditAboutDialogState();
}

class _EditAboutDialogState extends State<EditAboutDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _p1;
  late String _p2;
  late String _tagsStr;

  @override
  void initState() {
    super.initState();
    _p1 = widget.data.paragraph1;
    _p2 = widget.data.paragraph2;
    _tagsStr = widget.data.tags.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF131325),
      title: const Text('Edit About Section'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _p1,
                  decoration: const InputDecoration(labelText: 'Paragraph 1'),
                  maxLines: 3,
                  onSaved: (v) => _p1 = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _p2,
                  decoration: const InputDecoration(labelText: 'Paragraph 2'),
                  maxLines: 3,
                  onSaved: (v) => _p2 = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _tagsStr,
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  onSaved: (v) => _tagsStr = v ?? '',
                ),
                // Stats editing can be complex, skipping for brevity or add a basic text editor
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState?.save();
            final updated = AboutSectionData(
              paragraph1: _p1,
              paragraph2: _p2,
              tags: _tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
              stats: widget.data.stats, // Keep existing stats for now
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditContactDialog extends StatefulWidget {
  final ContactSectionData data;

  const EditContactDialog({super.key, required this.data});

  @override
  State<EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<EditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _phone;
  late String _linkedinUrl;
  late String _githubUrl;
  late String _youtubeUrl;
  late String _cvUrl;

  @override
  void initState() {
    super.initState();
    _email = widget.data.email;
    _phone = widget.data.phone;
    _linkedinUrl = widget.data.linkedinUrl;
    _githubUrl = widget.data.githubUrl;
    _youtubeUrl = widget.data.youtubeUrl;
    _cvUrl = widget.data.cvUrl;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF131325),
      title: const Text('Edit Contact Section'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (v) => _email = v ?? '',
                ),
                TextFormField(
                  initialValue: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onSaved: (v) => _phone = v ?? '',
                ),
                TextFormField(
                  initialValue: _linkedinUrl,
                  decoration: const InputDecoration(labelText: 'LinkedIn URL'),
                  onSaved: (v) => _linkedinUrl = v ?? '',
                ),
                TextFormField(
                  initialValue: _githubUrl,
                  decoration: const InputDecoration(labelText: 'GitHub URL'),
                  onSaved: (v) => _githubUrl = v ?? '',
                ),
                TextFormField(
                  initialValue: _youtubeUrl,
                  decoration: const InputDecoration(labelText: 'YouTube URL'),
                  onSaved: (v) => _youtubeUrl = v ?? '',
                ),
                TextFormField(
                  initialValue: _cvUrl,
                  decoration: const InputDecoration(labelText: 'CV URL'),
                  onSaved: (v) => _cvUrl = v ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState?.save();
            final updated = ContactSectionData(
              email: _email,
              phone: _phone,
              linkedinUrl: _linkedinUrl,
              githubUrl: _githubUrl,
              youtubeUrl: _youtubeUrl,
              cvUrl: _cvUrl,
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditExperienceDialog extends StatefulWidget {
  final ExperienceSectionData data;

  const EditExperienceDialog({super.key, required this.data});

  @override
  State<EditExperienceDialog> createState() => _EditExperienceDialogState();
}

class _EditExperienceDialogState extends State<EditExperienceDialog> {
  late List<ExperienceItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.data.items);
  }

  void _editItem(int index) async {
    final item = _items[index];
    final result = await showDialog<ExperienceItemData>(
      context: context,
      builder: (context) => _EditExperienceItemDialog(item: item),
    );
    if (result != null) {
      setState(() => _items[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF131325),
      title: const Text('Edit Experience Section'),
      content: SizedBox(
        width: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return ListTile(
              title: Text(item.role),
              subtitle: Text('${item.company} | ${item.duration}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyan),
                    onPressed: () => _editItem(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _items.removeAt(index)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final result = await showDialog<ExperienceItemData>(
              context: context,
              builder: (context) => const _EditExperienceItemDialog(item: ExperienceItemData(role: '', company: '', duration: '', description: '')),
            );
            if (result != null) {
              setState(() => _items.add(result));
            }
          },
          child: const Text('Add Experience'),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, ExperienceSectionData(items: _items));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditExperienceItemDialog extends StatefulWidget {
  final ExperienceItemData item;
  const _EditExperienceItemDialog({required this.item});

  @override
  State<_EditExperienceItemDialog> createState() => _EditExperienceItemDialogState();
}

class _EditExperienceItemDialogState extends State<_EditExperienceItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _role, _company, _duration, _description;

  @override
  void initState() {
    super.initState();
    _role = widget.item.role;
    _company = widget.item.company;
    _duration = widget.item.duration;
    _description = widget.item.description;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A30),
      title: const Text('Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(initialValue: _role, decoration: const InputDecoration(labelText: 'Role'), onSaved: (v) => _role = v ?? ''),
              TextFormField(initialValue: _company, decoration: const InputDecoration(labelText: 'Company'), onSaved: (v) => _company = v ?? ''),
              TextFormField(initialValue: _duration, decoration: const InputDecoration(labelText: 'Duration'), onSaved: (v) => _duration = v ?? ''),
              TextFormField(initialValue: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'), onSaved: (v) => _description = v ?? ''),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState?.save();
            Navigator.pop(context, ExperienceItemData(role: _role, company: _company, duration: _duration, description: _description));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditSkillsDialog extends StatefulWidget {
  final SkillsSectionData data;

  const EditSkillsDialog({super.key, required this.data});

  @override
  State<EditSkillsDialog> createState() => _EditSkillsDialogState();
}

class _EditSkillsDialogState extends State<EditSkillsDialog> {
  late List<SkillCategoryData> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.data.categories);
  }

  void _editCategory(int index) async {
    final cat = _categories[index];
    final result = await showDialog<SkillCategoryData>(
      context: context,
      builder: (context) => _EditSkillCategoryDialog(category: cat),
    );
    if (result != null) {
      setState(() => _categories[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF131325),
      title: const Text('Edit Skills Section'),
      content: SizedBox(
        width: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return ListTile(
              title: Text(cat.name),
              subtitle: Text(cat.skills.map((e) => '${e.name} (${(e.proficiency * 100).round()}%)').join(', ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyan),
                    onPressed: () => _editCategory(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _categories.removeAt(index)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final result = await showDialog<SkillCategoryData>(
              context: context,
              builder: (context) => const _EditSkillCategoryDialog(category: SkillCategoryData(name: '', colorHex: '0xFFFFFFFF', skills: [])),
            );
            if (result != null) {
              setState(() => _categories.add(result));
            }
          },
          child: const Text('Add Category'),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, SkillsSectionData(categories: _categories));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditSkillCategoryDialog extends StatefulWidget {
  final SkillCategoryData category;
  const _EditSkillCategoryDialog({required this.category});

  @override
  State<_EditSkillCategoryDialog> createState() => _EditSkillCategoryDialogState();
}

class _EditSkillCategoryDialogState extends State<_EditSkillCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _colorHex, _skillsStr;

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
    _colorHex = widget.category.colorHex;
    _skillsStr = widget.category.skills.map((e) => '${e.name}:${(e.proficiency * 100).round()}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A30),
      title: const Text('Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(initialValue: _name, decoration: const InputDecoration(labelText: 'Category Name'), onSaved: (v) => _name = v ?? ''),
              TextFormField(initialValue: _colorHex, decoration: const InputDecoration(labelText: 'Color Hex (e.g. 0xFF00F5FF)'), onSaved: (v) => _colorHex = v ?? ''),
              TextFormField(initialValue: _skillsStr, decoration: const InputDecoration(labelText: 'Skills (e.g. Flutter:95, Dart:90)'), maxLines: 3, onSaved: (v) => _skillsStr = v ?? ''),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState?.save();
            final parsedSkills = _skillsStr.split(',').map((e) {
              final parts = e.split(':');
              final name = parts[0].trim();
              final prof = parts.length > 1 ? (double.tryParse(parts[1].trim()) ?? 90) : 90.0;
              return SkillItemData(name: name, proficiency: prof / 100.0);
            }).where((e) => e.name.isNotEmpty).toList();
            Navigator.pop(context, SkillCategoryData(name: _name, colorHex: _colorHex, skills: parsedSkills));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
