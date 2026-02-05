import 'dart:ui'; // For BackdropFilter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_experience_section.dart';
import 'add_project_screen.dart';
import 'add_skill_section.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

// -----------------------------------------------------------------------------
// Dashboard Screen
// -----------------------------------------------------------------------------

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          // -------------------------------------------------------------------
          // Global Background
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // Main Scaffold
          // -------------------------------------------------------------------
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context),
            body: const TabBarView(
              children: [
                _ProjectsTab(),
                _ExperienceTab(),
                _SkillsTab(),
                EditProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      leading: const SizedBox.shrink(),
      backgroundColor: Colors.white.withOpacity(0.05),
      title: const Text(
        "Admin Panel",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          tooltip: "Logout",
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        const SizedBox(width: 10),
      ],
      bottom: const TabBar(
        labelColor: Color(0xFF6366F1),
        unselectedLabelColor: Colors.white60,
        indicatorColor: Color(0xFF6366F1),
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        tabs: [
          Tab(icon: Icon(Icons.dashboard_rounded), text: "Projects"),
          Tab(icon: Icon(Icons.history_edu_rounded), text: "Exp."),
          Tab(icon: Icon(Icons.bar_chart_rounded), text: "Skills"),
          Tab(icon: Icon(Icons.person_rounded), text: "Profile"),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PROJECTS TAB
// -----------------------------------------------------------------------------

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _GradientFAB(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProjectScreen()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No projects yet.",
                  style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _GlassCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: data['imageUrl'] != ''
                        ? Image.network(
                            data['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.white10,
                            child:
                                const Icon(Icons.image, color: Colors.white24),
                          ),
                  ),
                  title: Text(
                    data['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data['category'],
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: _ActionButtons(
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProjectScreen(projectDoc: doc),
                      ),
                    ),
                    onDelete: () => _deleteItem(context, 'projects', doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EXPERIENCE TAB
// -----------------------------------------------------------------------------

class _ExperienceTab extends StatelessWidget {
  const _ExperienceTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _GradientFAB(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExperienceScreen()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('experience')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _GlassCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_outline,
                        color: Color(0xFF10B981)),
                  ),
                  title: Text(
                    data['position'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['company'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: _ActionButtons(
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExperienceScreen(experienceDoc: doc),
                      ),
                    ),
                    onDelete: () => _deleteItem(context, 'experience', doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SKILLS TAB
// -----------------------------------------------------------------------------

class _SkillsTab extends StatelessWidget {
  const _SkillsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _GradientFAB(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddSkillScreen()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skills')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final level = (data['level'] ?? 0.0).toDouble();

              return _GlassCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: level,
                        backgroundColor: Colors.white10,
                        color: const Color(0xFF8B5CF6),
                      ),
                      Text(
                        "${(level * 100).toInt()}%",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  trailing: _ActionButtons(
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSkillScreen(skillDoc: doc),
                      ),
                    ),
                    onDelete: () => _deleteItem(context, 'skills', doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS
// -----------------------------------------------------------------------------

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
            icon: Icons.edit_rounded, color: Colors.blueAccent, onTap: onEdit),
        const SizedBox(width: 10),
        _IconBtn(
            icon: Icons.delete_rounded,
            color: Colors.redAccent,
            onTap: onDelete),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DELETE HELPER
// -----------------------------------------------------------------------------

void _deleteItem(BuildContext context, String collection, String docId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text("Delete Item?", style: TextStyle(color: Colors.white)),
      content: const Text(
        "This action cannot be undone.",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseFirestore.instance
                .collection(collection)
                .doc(docId)
                .delete();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Item Deleted"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child:
              const Text("Delete", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
}
