import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// -----------------------------------------------------------------------------
// Add / Edit Project Screen
// -----------------------------------------------------------------------------

class AddProjectScreen extends StatefulWidget {
  final DocumentSnapshot? projectDoc;

  const AddProjectScreen({super.key, this.projectDoc});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  // ---------------------------------------------------------------------------
  // Controllers & State
  // ---------------------------------------------------------------------------

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _techController = TextEditingController();
  final _githubController = TextEditingController();
  final _liveController = TextEditingController();

  String _selectedCategory = 'Mobile';
  final List<String> _categories = ['Mobile', 'Web'];

  //  Color Selection
  String _selectedColor = '6366F1';

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
    'Lime': const Color.fromARGB(255, 140, 143, 60),
  };

  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String? _existingImageUrl;

  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    if (widget.projectDoc != null) {
      final data = widget.projectDoc!.data() as Map<String, dynamic>;

      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _githubController.text = data['githubUrl'] ?? '';
      _liveController.text = data['liveUrl'] ?? '';
      _selectedCategory = data['category'] ?? 'Mobile';
      _existingImageUrl = data['imageUrl'];

      if (data['color'] != null) {
        _selectedColor = data['color'].toString().replaceAll('#', '');
      }

      List<dynamic> techs = data['technologies'] ?? [];
      _techController.text = techs.join(', ');
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _saveProject() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final cloudinary =
            CloudinaryPublic('dmx6js0vk', 'my_portfolio_preset', cache: false);

        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImage!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );

        imageUrl = response.secureUrl;
      }

      List<String> techList =
          _techController.text.split(',').map((e) => e.trim()).toList();

      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'imageUrl': imageUrl,
        'category': _selectedCategory,
        'technologies': techList,
        'githubUrl': _githubController.text.trim(),
        'liveUrl': _liveController.text.trim(),
        'color': '#$_selectedColor',
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.projectDoc != null) {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectDoc!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('projects').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Project Saved Successfully!'),
          backgroundColor: Color(0xFF10B981),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
              widget.projectDoc != null ? 'Edit Project' : 'Add New Project',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_existingImageUrl != null &&
                                _existingImageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 50,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Tap to select Image",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildGlassTextField(
                  controller: _titleController,
                  label: 'Project Title',
                  icon: Icons.title,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _descController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                // Category Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _techController,
                  label: 'Technologies (comma separated)',
                  icon: Icons.code,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _githubController,
                  label: 'GitHub Link',
                  icon: Icons.link,
                ),

                const SizedBox(height: 20),

                _buildGlassTextField(
                  controller: _liveController,
                  label: 'Live Link',
                  icon: Icons.launch,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Card Shadow Color",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

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
                              ? Border.all(
                                  color: Colors.white,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: entry.value.withOpacity(0.5),
                                    blurRadius: 10,
                                  )
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                // Save Button
                Container(
                  height: 55,
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
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            widget.projectDoc != null
                                ? 'Update Project'
                                : 'Save Project',
                            style: const TextStyle(
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
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
