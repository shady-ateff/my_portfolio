class PortfolioData {
  final HeroSectionData hero;
  final AboutSectionData about;
  final SkillsSectionData skills;
  final ExperienceSectionData experience;
  final ContactSectionData contact;

  const PortfolioData({
    required this.hero,
    required this.about,
    required this.skills,
    required this.experience,
    required this.contact,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      hero: HeroSectionData.fromJson(json['hero'] ?? {}),
      about: AboutSectionData.fromJson(json['about'] ?? {}),
      skills: SkillsSectionData.fromJson(json['skills'] ?? {}),
      experience: ExperienceSectionData.fromJson(json['experience'] ?? {}),
      contact: ContactSectionData.fromJson(json['contact'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hero': hero.toJson(),
      'about': about.toJson(),
      'skills': skills.toJson(),
      'experience': experience.toJson(),
      'contact': contact.toJson(),
    };
  }
}

class HeroSectionData {
  final String name;
  final List<String> subtitles;
  final bool isAvailableForWork;

  const HeroSectionData({
    this.name = 'Eng. Shady Atef',
    this.subtitles = const [
      'Flutter Tech Lead & Software Engineer',
      'Clean Architecture Specialist',
      'Building Scalable Mobile & Web Apps',
    ],
    this.isAvailableForWork = true,
  });

  factory HeroSectionData.fromJson(Map<String, dynamic> json) {
    return HeroSectionData(
      name: json['name'] ?? 'Eng. Shady Atef',
      subtitles: json['subtitles'] != null 
          ? List<String>.from(json['subtitles']) 
          : const [
              'Flutter Tech Lead & Software Engineer',
              'Clean Architecture Specialist',
              'Building Scalable Mobile & Web Apps',
            ],
      isAvailableForWork: json['isAvailableForWork'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subtitles': subtitles,
      'isAvailableForWork': isAvailableForWork,
    };
  }
}

class AboutSectionData {
  final String paragraph1;
  final String paragraph2;
  final List<String> tags;
  final List<StatData> stats;

  const AboutSectionData({
    this.paragraph1 = 'I am a Software Engineer and Flutter Tech Lead passionate about building scalable, high-performance applications using Clean Architecture.',
    this.paragraph2 = 'With a background in leading technical committees like RoboTech, I specialize in crafting seamless user experiences and robust backends. I love turning complex problems into elegant, efficient solutions.',
    this.tags = const ['Clean Architecture', 'TDD', 'Open Source', 'Tech Lead'],
    this.stats = const [
      StatData(number: '3+', label: 'Years\\nExperience', colorHex: '0xFF00F5FF'),
      StatData(number: '15+', label: 'Projects\\nBuilt', colorHex: '0xFF7B2FFF'),
      StatData(number: '8+', label: 'Tech\\nSkills', colorHex: '0xFF00E676'),
      StatData(number: '∞', label: 'Clean\\nCode', colorHex: '0xFFFFCA28'),
    ],
  });

  factory AboutSectionData.fromJson(Map<String, dynamic> json) {
    return AboutSectionData(
      paragraph1: json['paragraph1'] ?? 'I am a Software Engineer and Flutter Tech Lead passionate about building scalable, high-performance applications using Clean Architecture.',
      paragraph2: json['paragraph2'] ?? 'With a background in leading technical committees like RoboTech, I specialize in crafting seamless user experiences and robust backends. I love turning complex problems into elegant, efficient solutions.',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const ['Clean Architecture', 'TDD', 'Open Source', 'Tech Lead'],
      stats: json['stats'] != null 
          ? (json['stats'] as List).map((s) => StatData.fromJson(s)).toList()
          : const [
              StatData(number: '3+', label: 'Years\\nExperience', colorHex: '0xFF00F5FF'),
              StatData(number: '15+', label: 'Projects\\nBuilt', colorHex: '0xFF7B2FFF'),
              StatData(number: '8+', label: 'Tech\\nSkills', colorHex: '0xFF00E676'),
              StatData(number: '∞', label: 'Clean\\nCode', colorHex: '0xFFFFCA28'),
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paragraph1': paragraph1,
      'paragraph2': paragraph2,
      'tags': tags,
      'stats': stats.map((s) => s.toJson()).toList(),
    };
  }
}

class StatData {
  final String number;
  final String label;
  final String colorHex;

  const StatData({
    required this.number,
    required this.label,
    required this.colorHex,
  });

  factory StatData.fromJson(Map<String, dynamic> json) {
    return StatData(
      number: json['number'] ?? '',
      label: json['label'] ?? '',
      colorHex: json['colorHex'] ?? '0xFFFFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'label': label,
      'colorHex': colorHex,
    };
  }
}

class SkillsSectionData {
  final List<SkillCategoryData> categories;

  const SkillsSectionData({
    this.categories = const [
      SkillCategoryData(
        name: 'Mobile Development',
        colorHex: '0xFF00F5FF',
        skills: [
          SkillItemData(name: 'Flutter (Dart)', proficiency: 0.95),
          SkillItemData(name: 'State Management (Bloc, Provider)', proficiency: 0.9),
          SkillItemData(name: 'Clean Architecture', proficiency: 0.9),
          SkillItemData(name: 'Animations', proficiency: 0.85),
          SkillItemData(name: 'Platform Channels', proficiency: 0.8),
        ],
      ),
      SkillCategoryData(
        name: 'Backend & Services',
        colorHex: '0xFF7B2FFF',
        skills: [
          SkillItemData(name: 'Firebase (Auth, Firestore, Cloud Functions)', proficiency: 0.9),
          SkillItemData(name: 'RESTful APIs', proficiency: 0.85),
          SkillItemData(name: 'PostgreSQL', proficiency: 0.8),
          SkillItemData(name: 'Node.js Basics', proficiency: 0.75),
        ],
      ),
      SkillCategoryData(
        name: 'Tools & Practices',
        colorHex: '0xFF00E676',
        skills: [
          SkillItemData(name: 'Git / GitHub', proficiency: 0.95),
          SkillItemData(name: 'CI/CD (GitHub Actions)', proficiency: 0.85),
          SkillItemData(name: 'TDD (Test-Driven Development)', proficiency: 0.8),
          SkillItemData(name: 'Agile / Scrum', proficiency: 0.9),
        ],
      ),
    ],
  });

  factory SkillsSectionData.fromJson(Map<String, dynamic> json) {
    return SkillsSectionData(
      categories: json['categories'] != null
          ? (json['categories'] as List).map((c) => SkillCategoryData.fromJson(c as Map<String, dynamic>)).toList()
          : const [
              SkillCategoryData(
                name: 'Mobile Development',
                colorHex: '0xFF00F5FF',
                skills: [
                  SkillItemData(name: 'Flutter (Dart)', proficiency: 0.95),
                  SkillItemData(name: 'State Management (Bloc, Provider)', proficiency: 0.9),
                  SkillItemData(name: 'Clean Architecture', proficiency: 0.9),
                  SkillItemData(name: 'Animations', proficiency: 0.85),
                  SkillItemData(name: 'Platform Channels', proficiency: 0.8),
                ],
              ),
              SkillCategoryData(
                name: 'Backend & Services',
                colorHex: '0xFF7B2FFF',
                skills: [
                  SkillItemData(name: 'Firebase (Auth, Firestore, Cloud Functions)', proficiency: 0.9),
                  SkillItemData(name: 'RESTful APIs', proficiency: 0.85),
                  SkillItemData(name: 'PostgreSQL', proficiency: 0.8),
                  SkillItemData(name: 'Node.js Basics', proficiency: 0.75),
                ],
              ),
              SkillCategoryData(
                name: 'Tools & Practices',
                colorHex: '0xFF00E676',
                skills: [
                  SkillItemData(name: 'Git / GitHub', proficiency: 0.95),
                  SkillItemData(name: 'CI/CD (GitHub Actions)', proficiency: 0.85),
                  SkillItemData(name: 'TDD (Test-Driven Development)', proficiency: 0.8),
                  SkillItemData(name: 'Agile / Scrum', proficiency: 0.9),
                ],
              ),
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}

class SkillCategoryData {
  final String name;
  final String colorHex;
  final List<SkillItemData> skills;

  const SkillCategoryData({
    required this.name,
    required this.colorHex,
    required this.skills,
  });

  factory SkillCategoryData.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'] as List?;
    final parsedSkills = <SkillItemData>[];
    if (rawSkills != null) {
      for (final s in rawSkills) {
        if (s is String) {
          parsedSkills.add(SkillItemData(name: s, proficiency: 0.9));
        } else if (s is Map) {
          parsedSkills.add(SkillItemData.fromJson(s as Map<String, dynamic>));
        }
      }
    }
    return SkillCategoryData(
      name: json['name'] ?? '',
      colorHex: json['colorHex'] ?? '0xFFFFFFFF',
      skills: parsedSkills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'colorHex': colorHex,
      'skills': skills.map((s) => s.toJson()).toList(),
    };
  }
}

class SkillItemData {
  final String name;
  final double proficiency;

  const SkillItemData({
    required this.name,
    this.proficiency = 0.9,
  });

  factory SkillItemData.fromJson(Map<String, dynamic> json) {
    return SkillItemData(
      name: json['name'] ?? '',
      proficiency: (json['proficiency'] as num?)?.toDouble() ?? 0.9,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'proficiency': proficiency,
    };
  }
}

class ExperienceSectionData {
  final List<ExperienceItemData> items;

  const ExperienceSectionData({
    this.items = const [
      ExperienceItemData(
        role: 'Flutter Tech Lead',
        company: 'RoboTech',
        duration: '2023 - Present',
        description: 'Led a team of 5 mobile developers. Architected the main app using Clean Architecture and Bloc. Reduced build times by 40% and improved crash-free sessions to 99.9%.',
      ),
      ExperienceItemData(
        role: 'Mobile Software Engineer',
        company: 'Digital Egypt Pioneers Initiative (DEPI)',
        duration: '2022 - 2023',
        description: 'Developed cross-platform mobile solutions. Integrated RESTful APIs and real-time Firebase databases. Participated in Agile sprint planning and code reviews.',
      ),
    ],
  });

  factory ExperienceSectionData.fromJson(Map<String, dynamic> json) {
    return ExperienceSectionData(
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ExperienceItemData.fromJson(i)).toList()
          : const [
              ExperienceItemData(
                role: 'Flutter Tech Lead',
                company: 'RoboTech',
                duration: '2023 - Present',
                description: 'Led a team of 5 mobile developers. Architected the main app using Clean Architecture and Bloc. Reduced build times by 40% and improved crash-free sessions to 99.9%.',
              ),
              ExperienceItemData(
                role: 'Mobile Software Engineer',
                company: 'Digital Egypt Pioneers Initiative (DEPI)',
                duration: '2022 - 2023',
                description: 'Developed cross-platform mobile solutions. Integrated RESTful APIs and real-time Firebase databases. Participated in Agile sprint planning and code reviews.',
              ),
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class ExperienceItemData {
  final String role;
  final String company;
  final String duration;
  final String description;

  const ExperienceItemData({
    required this.role,
    required this.company,
    required this.duration,
    required this.description,
  });

  factory ExperienceItemData.fromJson(Map<String, dynamic> json) {
    return ExperienceItemData(
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'description': description,
    };
  }
}

class ContactSectionData {
  final String email;
  final String phone;
  final String linkedinUrl;
  final String githubUrl;
  final String youtubeUrl;
  final String cvUrl;

  const ContactSectionData({
    this.email = 'shadyatefbakry@gmail.com',
    this.phone = '+20 1016075060',
    this.linkedinUrl = 'https://linkedin.com/in/shadyatef',
    this.githubUrl = 'https://github.com/shady-ateff',
    this.youtubeUrl = '',
    this.cvUrl = '',
  });

  factory ContactSectionData.fromJson(Map<String, dynamic> json) {
    return ContactSectionData(
      email: json['email'] ?? 'shadyatefbakry@gmail.com',
      phone: json['phone'] ?? '+20 1016075060',
      linkedinUrl: json['linkedinUrl'] ?? 'https://linkedin.com/in/shadyatef',
      githubUrl: json['githubUrl'] ?? 'https://github.com/shady-ateff',
      youtubeUrl: json['youtubeUrl'] ?? '',
      cvUrl: json['cvUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'youtubeUrl': youtubeUrl,
      'cvUrl': cvUrl,
    };
  }
}
