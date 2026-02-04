import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSkillScreen extends StatefulWidget {
  final DocumentSnapshot? skillDoc;
  const AddSkillScreen({super.key, this.skillDoc});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _nameController = TextEditingController();
  double _percentage = 0.5;
  String _selectedColor = '6366F1';
  bool _isLoading = false;

  final Map<String, Color> _colors = {
    'Indigo': const Color(0xFF6366F1),
    'Blue': const Color(0xFF3B82F6),
    'Green': const Color.fromARGB(255, 9, 225, 59),
    'Red': const Color(0xFFEF4444),
    'Purple': const Color(0xFF8B5CF6),
    'Orange': const Color(0xFFF97316),
    'Yellow': const Color(0xFFEAB308),
    'Teal': const Color(0xFF14B8A6),
    'Black': const Color(0xFF000000),
    'Pink': const Color(0xFFFF00FF),
    'Cyan': const Color(0xFF00FFFF),
    'Gray': const Color(0xFF808080),
    'Brown': const Color(0xFFA52A2A),
    'Lime': const Color(0xFF00FF00),
  };

  @override
  void initState() {
    super.initState();
    if (widget.skillDoc != null) {
      final data = widget.skillDoc!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _percentage = (data['level'] ?? 0.5).toDouble();
      _selectedColor = (data['color'] ?? '#6366F1').replaceAll('#', '');
    }
  }

  Future<void> _saveSkill() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'level': _percentage,
        'color': '#$_selectedColor',
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.skillDoc != null) {
        await FirebaseFirestore.instance
            .collection('skills')
            .doc(widget.skillDoc!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('skills').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Skill Saved Successfully!'),
          backgroundColor: Color(0xFF8B5CF6),
        ));
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            title: Text(widget.skillDoc != null ? 'Edit Skill' : 'Add Skill',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
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
                    controller: _nameController,
                    label: 'Skill Name',
                    icon: Icons.code),
                const SizedBox(height: 30),

                // Slider Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text("Proficiency: ${(_percentage * 100).toInt()}%",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Slider(
                        value: _percentage,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (val) => setState(() => _percentage = val),
                        activeColor: _colors.entries
                            .firstWhere(
                                (e) => e.key == _getColorName(_selectedColor),
                                orElse: () => _colors.entries.first)
                            .value,
                        inactiveColor: Colors.white24,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("Pick Color",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: _colors.entries.map((entry) {
                    final colorHex = entry.value.value
                        .toRadixString(16)
                        .substring(2)
                        .toUpperCase();
                    final isSelected = _selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorHex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 50 : 40,
                        height: isSelected ? 50 : 40,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: entry.value.withOpacity(0.5),
                                      blurRadius: 10)
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 50),
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Skill',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
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
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }

  String _getColorName(String hex) {
    for (var entry in _colors.entries) {
      if (entry.value.value.toRadixString(16).substring(2).toUpperCase() ==
          hex) {
        return entry.key;
      }
    }
    return 'Indigo';
  }
}
