import 'dart:ui'; // For BackdropFilter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_portfolio_main/admin/add_experience_section.dart';
import 'package:my_portfolio_main/admin/add_skill_section.dart';

import 'add_project_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          // 1. Global Dark Gradient Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // Dark Navy
                  Color(0xFF1E293B), // Slate
                ],
              ),
            ),
          ),

          // 2. Main Content
          Scaffold(
            backgroundColor: Colors.transparent, // Let gradient show through
            appBar: AppBar(
              title: const Text("Admin Panel",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white.withOpacity(0.05), // Glassy Header
              elevation: 0,
              centerTitle: true,
              leading: Container(), // Hide back button
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  tooltip: "Logout",
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const LoginScreen()));
                    }
                  },
                ),
                const SizedBox(width: 10),
              ],
              bottom: const TabBar(
                labelColor: Color(0xFF6366F1), // Indigo for active tab
                unselectedLabelColor: Colors.white60,
                indicatorColor: Color(0xFF6366F1),
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: "Projects"),
                  Tab(icon: Icon(Icons.history_edu_rounded), text: "Exp."),
                  Tab(icon: Icon(Icons.bar_chart_rounded), text: "Skills"),
                  Tab(icon: Icon(Icons.person_rounded), text: "Profile"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildProjectList(context),
                _buildExperienceList(context),
                _buildSkillList(context),
                const EditProfileScreen(), // You might need to style this screen separately later
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ PROJECTS LIST
  Widget _buildProjectList(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildGradientFAB(
        context,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddProjectScreen())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)));
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

              return _buildGlassCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: data['imageUrl'] != ''
                        ? Image.network(data['imageUrl'],
                            width: 60, height: 60, fit: BoxFit.cover)
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
                        fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data['category'],
                      style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: Icons.edit_rounded,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddProjectScreen(projectDoc: doc))),
                      ),
                      const SizedBox(width: 10),
                      _buildIconButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        onTap: () => _deleteItem(context, 'projects', doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 2️⃣ EXPERIENCE LIST
  Widget _buildExperienceList(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildGradientFAB(
        context,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddExperienceScreen())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('experience')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildGlassCard(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: Icons.edit_rounded,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddExperienceScreen(experienceDoc: doc))),
                      ),
                      const SizedBox(width: 10),
                      _buildIconButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        onTap: () => _deleteItem(context, 'experience', doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 3️⃣ SKILLS LIST
  Widget _buildSkillList(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildGradientFAB(
        context,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddSkillScreen())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skills')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              double level = (data['level'] ?? 0.0).toDouble();

              return _buildGlassCard(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: Icons.edit_rounded,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddSkillScreen(skillDoc: doc))),
                      ),
                      const SizedBox(width: 10),
                      _buildIconButton(
                        icon: Icons.delete_rounded,
                        color: Colors.redAccent,
                        onTap: () => _deleteItem(context, 'skills', doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🎨 HELPER: Glassmorphism Card
  Widget _buildGlassCard({required Widget child}) {
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

  // 🎨 HELPER: Gradient FAB
  Widget _buildGradientFAB(BuildContext context,
      {required VoidCallback onPressed}) {
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

  // 🎨 HELPER: Custom Icon Button
  Widget _buildIconButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
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

  // DELETE HELPER FUNCTION
  void _deleteItem(BuildContext context, String collection, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text("Delete Item?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection(collection)
                  .doc(docId)
                  .delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Item Deleted"),
                  backgroundColor: Colors.redAccent,
                ));
              }
            },
            child:
                const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
