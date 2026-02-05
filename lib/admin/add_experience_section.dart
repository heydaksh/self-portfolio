import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// Add / Edit Experience Screen
// -----------------------------------------------------------------------------

class AddExperienceScreen extends StatefulWidget {
  final DocumentSnapshot? experienceDoc;

  const AddExperienceScreen({super.key, this.experienceDoc});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  // ---------------------------------------------------------------------------
  // Controllers & State
  // ---------------------------------------------------------------------------

  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _periodController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _techController = TextEditingController();

  bool _isCurrentJob = false;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    if (widget.experienceDoc != null) {
      final data = widget.experienceDoc!.data() as Map<String, dynamic>;

      _companyController.text = data['company'] ?? '';
      _positionController.text = data['position'] ?? '';
      _periodController.text = data['period'] ?? '';
      _locationController.text = data['location'] ?? '';
      _descController.text = data['description'] ?? '';
      _isCurrentJob = data['isCurrentJob'] ?? false;

      List<dynamic> ach = data['achievements'] ?? [];
      _achievementsController.text = ach.join('\n');

      List<dynamic> tech = data['technologies'] ?? [];
      _techController.text = tech.join(', ');
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _saveExperience() async {
    if (_companyController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      List<String> achievementsList = _achievementsController.text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      List<String> techList =
          _techController.text.split(',').map((e) => e.trim()).toList();

      Map<String, dynamic> data = {
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'period': _periodController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descController.text.trim(),
        'achievements': achievementsList,
        'technologies': techList,
        'isCurrentJob': _isCurrentJob,
        'color': '#10B981',
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.experienceDoc != null) {
        await FirebaseFirestore.instance
            .collection('experience')
            .doc(widget.experienceDoc!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('experience').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Experience Saved Successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              widget.experienceDoc != null
                  ? 'Edit Experience'
                  : 'Add Experience',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.05),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildGlassTextField(
                  controller: _positionController,
                  label: 'Position / Role',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _companyController,
                  label: 'Company Name',
                  icon: Icons.business,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildGlassTextField(
                        controller: _periodController,
                        label: 'Period',
                        icon: Icons.date_range,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildGlassTextField(
                        controller: _locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Current job switch
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Currently working here?",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Switch(
                        value: _isCurrentJob,
                        onChanged: (val) => setState(() => _isCurrentJob = val),
                        activeColor: const Color(0xFF10B981),
                        activeTrackColor:
                            const Color(0xFF10B981).withOpacity(0.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _descController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _achievementsController,
                  label: 'Achievements (One per line)',
                  icon: Icons.star_border,
                  maxLines: 5,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _techController,
                  label: 'Technologies (comma separated)',
                  icon: Icons.code,
                ),

                const SizedBox(height: 40),

                // Save button
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveExperience,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Experience',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
      ),
    );
  }
}
