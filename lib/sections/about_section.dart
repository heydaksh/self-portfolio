import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/responsive_utils.dart';

// --------------------------------------------------------------------------
// Model
// --------------------------------------------------------------------------

class Skill {
  final String name;
  final double level;
  final Color color;

  Skill(this.name, this.level, this.color);

  factory Skill.fromMap(Map<String, dynamic> data) {
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) {
        return const Color(0xFF6366F1);
      }
      try {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (e) {
        return const Color(0xFF6366F1);
      }
    }

    return Skill(
      data['name'] ?? '',
      (data['level'] ?? 0.0).toDouble(),
      parseColor(data['color']),
    );
  }
}

// --------------------------------------------------------------------------
// About Section
// --------------------------------------------------------------------------

class AboutSection extends StatefulWidget {
  final bool isVisible;

  const AboutSection({super.key, this.isVisible = false});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with SingleTickerProviderStateMixin {
  // ------------------------------------------------------------------------
  // Streams
  // ------------------------------------------------------------------------

  late Stream<DocumentSnapshot> _bioStream;
  late Stream<QuerySnapshot> _projectCountStream;
  late Stream<QuerySnapshot> _skillStream;

  // ------------------------------------------------------------------------
  // Animations
  // ------------------------------------------------------------------------

  late AnimationController _animationController;
  late Animation<double> _skillsAnimation;

  // ------------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _bioStream = FirebaseFirestore.instance
        .collection('profile')
        .doc('main_info')
        .snapshots();

    _projectCountStream =
        FirebaseFirestore.instance.collection('projects').snapshots();

    _skillStream = FirebaseFirestore.instance.collection('skills').snapshots();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _skillsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AboutSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.reset();
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: ResponsiveUtils.sectionPadding(context),
        child: Column(
          children: [
            _buildSectionHeader(context),
            ResponsiveUtils.verticalSpace(
              context,
              ResponsiveUtils.isDesktop(context) ? 80 : 50,
            ),
            ResponsiveUtils.isDesktop(context)
                ? _buildDesktopLayout(context)
                : _buildMobileLayout(context),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  // Layouts
  // ------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildAboutContent(context),
        ),
        ResponsiveUtils.horizontalSpace(context, 80),
        Expanded(
          flex: 1,
          child: _buildSkillsSection(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildAboutContent(context),
        ResponsiveUtils.verticalSpace(context, 50),
        _buildSkillsSection(context),
      ],
    );
  }

  // ------------------------------------------------------------------------
  // Section parts
  // ------------------------------------------------------------------------

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: ResponsiveUtils.paddingSymmetric(
            context,
            horizontal: 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 50)),
          ),
          child: Text(
            'About Me',
            style: TextStyle(
              color: const Color(0xFF6366F1),
              fontSize: ResponsiveUtils.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        ResponsiveUtils.verticalSpace(context, 16),
        Text(
          'Passionate Developer',
          style: ResponsiveUtils.headingLarge(context).copyWith(
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildAboutContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(context),
        ResponsiveUtils.verticalSpace(context, 40),

        // DYNAMIC BIO STREAM
        StreamBuilder<DocumentSnapshot>(
          stream: _bioStream,
          builder: (context, snapshot) {
            String bioText =
                'Hello! I\'m a passionate Flutter developer with a love for creating beautiful, functional, and user-friendly mobile applications.';

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              if (data['bio'] != null && data['bio'].toString().isNotEmpty) {
                bioText = data['bio'];
              }
            }

            return Text(
              bioText,
              style: ResponsiveUtils.bodyLarge(context).copyWith(
                color: Colors.grey[700],
                height: 1.8,
              ),
            );
          },
        ),
        // END STREAM

        ResponsiveUtils.verticalSpace(context, 30),
        _buildFeatures(context),
      ]
          .animate(interval: 100.ms)
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _bioStream,
            builder: (context, snapshot) {
              String experience = '5+';

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                if (data['experience'] != null &&
                    data['experience'].toString().isNotEmpty) {
                  experience = data['experience'];
                }
              }

              return _StatCard(
                number: experience,
                label: 'Months\nExperience',
              );
            },
          ),
        ),
        ResponsiveUtils.horizontalSpace(context, 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _projectCountStream,
            builder: (context, snapshot) {
              int projectCount = 0;

              if (snapshot.hasData) {
                projectCount = snapshot.data!.docs.length;
              }

              return _StatCard(
                number: projectCount > 0 ? '${projectCount - 1}+' : '0+',
                label: 'Projects\nCompleted',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      {
        'icon': Icons.mobile_friendly,
        'title': 'Mobile First',
        'desc': 'Responsive design for all devices'
      },
      {
        'icon': Icons.speed,
        'title': 'Fast Performance',
        'desc': 'Optimized for speed and efficiency'
      },
      {
        'icon': Icons.brush,
        'title': 'Modern UI',
        'desc': 'Beautiful and intuitive interfaces'
      },
    ];

    return Column(
      children: features
          .map(
            (feature) => _FeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              desc: feature['desc'] as String,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills & Technologies',
          style: ResponsiveUtils.headingMedium(context).copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
        ResponsiveUtils.verticalSpace(context, 24),

        // Dynamic Skills List
        StreamBuilder<QuerySnapshot>(
          stream: _skillStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("No skills added yet.");
            }

            final skills = snapshot.data!.docs.map((doc) {
              return Skill.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            return Column(
              children: skills
                  .map(
                    (skill) => _SkillItem(
                      skill: skill,
                      animation: _skillsAnimation,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ]
          .animate(interval: 50.ms)
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, end: 0),
    );
  }
}

// --------------------------------------------------------------------------
// Helper Widgets (Keep these at bottom of file)
// --------------------------------------------------------------------------

class _SkillItem extends StatefulWidget {
  final Skill skill;
  final Animation<double> animation;

  const _SkillItem({required this.skill, required this.animation});

  @override
  State<_SkillItem> createState() => _SkillItemState();
}

class _SkillItemState extends State<_SkillItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: ResponsiveUtils.paddingOnly(context, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedDefaultTextStyle(
                  duration: 200.ms,
                  style: ResponsiveUtils.headingSmall(context).copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
                  ),
                  child: Text(widget.skill.name),
                ),
                Text(
                  '${(widget.skill.level * 100).toInt()}%',
                  style: ResponsiveUtils.bodySmall(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            ResponsiveUtils.verticalSpace(context, 8),
            AnimatedBuilder(
              animation: widget.animation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: 300.ms,
                  height: ResponsiveUtils.height(context, _isHovered ? 8 : 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius(context, 4),
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: widget.skill.color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.skill.level * widget.animation.value,
                    child: AnimatedContainer(
                      duration: 300.ms,
                      decoration: BoxDecoration(
                        color: widget.skill.color,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius(context, 4),
                        ),
                        gradient: _isHovered
                            ? LinearGradient(
                                colors: [
                                  widget.skill.color,
                                  widget.skill.color.withOpacity(0.7),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        padding: ResponsiveUtils.paddingAll(context, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF6366F1).withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 30 : 20,
              offset: Offset(0, _isHovered ? 15 : 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.number,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(
                  context,
                  ResponsiveUtils.isMobile(context) ? 24 : 32,
                ),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6366F1),
              ),
            ),
            ResponsiveUtils.verticalSpace(context, 8),
            Text(
              widget.label,
              style: ResponsiveUtils.bodySmall(context).copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  State<_FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<_FeatureItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: ResponsiveUtils.paddingOnly(context, bottom: 20),
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          padding: ResponsiveUtils.paddingAll(context, 12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.transparent,
            borderRadius:
                BorderRadius.circular(ResponsiveUtils.radius(context, 16)),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: 300.ms,
                width: ResponsiveUtils.width(context, _isHovered ? 56 : 48),
                height: ResponsiveUtils.height(context, _isHovered ? 56 : 48),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1)
                      .withOpacity(_isHovered ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.radius(context, 12),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFF6366F1),
                  size: ResponsiveUtils.width(context, _isHovered ? 28 : 24),
                ),
              ),
              ResponsiveUtils.horizontalSpace(context, 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: ResponsiveUtils.headingSmall(context).copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight:
                            _isHovered ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.desc,
                      style: ResponsiveUtils.bodySmall(context).copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
