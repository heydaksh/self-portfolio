import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// -----------------------------------------------------------------------------
// Edit Profile Screen
// -----------------------------------------------------------------------------

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _resumeController = TextEditingController();
  final _experienceController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Image picker & state
  // ---------------------------------------------------------------------------

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
    _loadProfileData();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('profile')
          .doc('main_info')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _locationController.text = data['location'] ?? '';
        _githubController.text = data['github'] ?? '';
        _linkedinController.text = data['linkedin'] ?? '';
        _twitterController.text = data['twitter'] ?? '';
        _resumeController.text = data['resume'] ?? '';
        _experienceController.text = data['experience'] ?? '';
        _existingImageUrl = data['photoUrl'];
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Image picking
  // ---------------------------------------------------------------------------

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  // ---------------------------------------------------------------------------
  // Save profile
  // ---------------------------------------------------------------------------

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String photoUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final cloudinary =
            CloudinaryPublic('dmx6js0vk', 'my_portfolio_preset', cache: false);

        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImage!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );

        photoUrl = response.secureUrl;
      }

      await FirebaseFirestore.instance
          .collection('profile')
          .doc('main_info')
          .set({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'github': _githubController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'resume': _resumeController.text.trim(),
        'experience': _experienceController.text.trim(),
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated Successfully!'),
            backgroundColor: Color(0xFF6366F1),
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
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📸 Profile photo picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6366F1),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                  )
                                : (_existingImageUrl != null &&
                                        _existingImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        _existingImageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.white.withOpacity(0.05),
                                        child: const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.white24,
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("Personal Info"),
                _buildGlassTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _bioController,
                  label: 'Bio',
                  icon: Icons.info_outline,
                  maxLines: 4,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _experienceController,
                  label: 'Experience (e.g. 5+ Months)',
                  icon: Icons.work_history,
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("Contact Info"),
                _buildGlassTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("Links"),
                _buildGlassTextField(
                  controller: _githubController,
                  label: 'GitHub URL',
                  icon: Icons.code,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn URL',
                  icon: Icons.link,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _twitterController,
                  label: 'Twitter URL',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 15),
                _buildGlassTextField(
                  controller: _resumeController,
                  label: 'Resume (Google Drive)',
                  icon: Icons.description,
                ),
                const SizedBox(height: 40),

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
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
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
          );
  }

  // ---------------------------------------------------------------------------
  // Small helpers
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

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
