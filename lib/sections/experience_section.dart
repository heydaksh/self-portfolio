import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// VisibilityDetector hataya (Conflict ka karan)

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Controllers & Streams
  // ---------------------------------------------------------------------------

  late AnimationController _animationController;

  // 🟢 FIX 1: Stream ko init mein load karo
  late Stream<QuerySnapshot> _experienceStream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 🟢 Fix: Load stream once
    _experienceStream = FirebaseFirestore.instance
        .collection('experience')
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Animation start karo
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFF6366F1).withOpacity(0.02),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 20,
          vertical: isDesktop ? 100 : 60,
        ),
        child: Column(
          children: [
            _buildSectionHeader(),
            SizedBox(height: isDesktop ? 80 : 50),

            // 🔴 FIX: Use persistent stream
            StreamBuilder<QuerySnapshot>(
              stream: _experienceStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No experience added yet.");
                }

                final experiences = snapshot.data!.docs.map((doc) {
                  return Experience.fromMap(
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                return _buildTimeline(isDesktop, experiences);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header & Timeline
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Text(
            'Experience',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Professional Journey',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'My professional experience and the amazing companies I\'ve worked with',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimeline(bool isDesktop, List<Experience> experiences) {
    return Column(
      children: experiences.asMap().entries.map((entry) {
        final index = entry.key;
        final experience = entry.value;
        final isLast = index == experiences.length - 1;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final double start = (index * 0.2).clamp(0.0, 0.8);
            final double end = (start + 0.4).clamp(0.0, 1.0);

            final curve = CurvedAnimation(
              parent: _animationController,
              curve: Interval(start, end, curve: Curves.easeOutQuart),
            );

            return Transform.translate(
              offset: Offset(0, 50 * (1 - curve.value)),
              child: Opacity(
                opacity: curve.value,
                child: _ExperienceItem(
                  experience: experience,
                  isLast: isLast,
                  isDesktop: isDesktop,
                  index: index,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Experience Item
// -----------------------------------------------------------------------------

class _ExperienceItem extends StatefulWidget {
  final Experience experience;
  final bool isLast;
  final bool isDesktop;
  final int index;

  const _ExperienceItem({
    required this.experience,
    required this.isLast,
    required this.isDesktop,
    required this.index,
  });

  @override
  State<_ExperienceItem> createState() => _ExperienceItemState();
}

class _ExperienceItemState extends State<_ExperienceItem> {
  bool _isHovered = false;

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isHovered ? 20 : 16,
              height: _isHovered ? 20 : 16,
              decoration: BoxDecoration(
                color: widget.experience.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.experience.color.withOpacity(0.3),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.experience.isCurrentJob
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            if (!widget.isLast)
              Container(
                width: 2,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.experience.color.withOpacity(0.5),
                      Colors.grey[300]!,
                    ],
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered
                      ? widget.experience.color.withOpacity(0.2)
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? widget.experience.color.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isHovered ? 30 : 20,
                    offset: Offset(0, _isHovered ? 15 : 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExperienceHeader(widget.experience, widget.isDesktop),
                  const SizedBox(height: 16),
                  _buildExperienceDescription(widget.experience),
                  const SizedBox(height: 24),
                  _buildAchievements(widget.experience),
                  const SizedBox(height: 24),
                  _buildTechnologies(widget.experience),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub widgets
  // ---------------------------------------------------------------------------

  Widget _buildExperienceHeader(Experience experience, bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          experience.position,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (experience.isCurrentJob) ...[
                          const SizedBox(width: 12),
                          _buildCurrentBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience.company,
                      style: TextStyle(
                        fontSize: 18,
                        color: experience.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPeriodAndLocation(experience),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      experience.position,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (experience.isCurrentJob) ...[
                    const SizedBox(width: 8),
                    _buildCurrentBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                experience.company,
                style: TextStyle(
                  fontSize: 16,
                  color: experience.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildPeriodAndLocation(
                experience,
                isMobile: true,
              ),
            ],
          );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Present',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPeriodAndLocation(
    Experience experience, {
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: experience.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            experience.period,
            style: TextStyle(
              color: experience.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              experience.location,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceDescription(Experience experience) {
    return Text(
      experience.description,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[700],
        height: 1.6,
      ),
    );
  }

  Widget _buildAchievements(Experience experience) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars_rounded, color: experience.color, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Key Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...experience.achievements.map(
          (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: experience.color.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    achievement,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnologies(Experience experience) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: experience.technologies
          .map(
            (tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                tech,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

class Experience {
  final String company;
  final String position;
  final String period;
  final String location;
  final String description;
  final List<String> achievements;
  final List<String> technologies;
  final Color color;
  final bool isCurrentJob;

  const Experience({
    required this.company,
    required this.position,
    required this.period,
    required this.location,
    required this.description,
    required this.achievements,
    required this.technologies,
    required this.color,
    required this.isCurrentJob,
  });

  factory Experience.fromMap(Map<String, dynamic> data) {
    Color parseColor(dynamic colorData) {
      if (colorData is String) {
        if (colorData.isEmpty) return const Color(0xFF6366F1);
        try {
          final buffer = StringBuffer();
          if (colorData.length == 6 || colorData.length == 7) {
            buffer.write('ff');
          }
          buffer.write(colorData.replaceFirst('#', ''));
          return Color(int.parse(buffer.toString(), radix: 16));
        } catch (e) {
          return const Color(0xFF6366F1);
        }
      }
      return const Color(0xFF6366F1);
    }

    return Experience(
      company: data['company'] ?? 'Unknown Company',
      position: data['position'] ?? 'Developer',
      period: data['period'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      achievements: List<String>.from(data['achievements'] ?? []),
      technologies: List<String>.from(data['technologies'] ?? []),
      color: parseColor(data['color']),
      isCurrentJob: data['isCurrentJob'] ?? false,
    );
  }
}
