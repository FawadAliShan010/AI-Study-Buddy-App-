import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/upload_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final photoURL = profileProvider.profile?.photoURL ?? widget.user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E17),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),
        actions: [
          if (_isUploadingImage || uploadProvider.isUploading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
            ),
          TextButton(
            onPressed: (_isLoading || _isUploadingImage || uploadProvider.isUploading)
                ? null
                : _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E17),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image with Upload
                GestureDetector(
                  onTap: (_isUploadingImage || uploadProvider.isUploading)
                      ? null
                      : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.secondaryGradient,
                          boxShadow: AppShadows.glow,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                              : photoURL != null && photoURL.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              photoURL,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_rounded, size: 50),
                            ),
                          )
                              : const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Upload overlay
                      if (_isUploadingImage || uploadProvider.isUploading)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      // Camera icon overlay
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to change profile picture',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: GoogleFonts.inter(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user?.email ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Upload progress indicator
                if (_isUploadingImage || uploadProvider.isUploading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: uploadProvider.uploadProgress,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uploading... ${(uploadProvider.uploadProgress * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Show selected image name
                if (_selectedImage != null && !_isUploadingImage)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New image selected',
                          style: GoogleFonts.inter(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isUploadingImage || uploadProvider.isUploading)
                        ? null
                        : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (_isLoading || _isUploadingImage || uploadProvider.isUploading)
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: (_isLoading || _isUploadingImage || uploadProvider.isUploading)
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ IMAGE PICKER METHOD ============

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Auto-upload when image is selected
      await _uploadProfileImage();
    }
  }

  // ============ UPLOAD PROFILE IMAGE ============

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Helpers.showSnackBar(context, 'Please login first', isError: true);
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);

      final success = await uploadProvider.uploadFile(
        file: _selectedImage!,
        userId: user.uid,
        folder: 'profile',
        isProfileImage: true,
      );

      if (success) {
        // Reload profile to get updated photo URL
        await profileProvider.loadProfile(user.uid);

        if (mounted) {
          Helpers.showSnackBar(context, 'Profile image updated successfully!');
          setState(() {
            _selectedImage = null;
            _isUploadingImage = false;
          });
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Failed to update profile image: ${uploadProvider.error}',
            isError: true,
          );
          setState(() => _isUploadingImage = false);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to upload image: $e',
          isError: true,
        );
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // ============ SAVE PROFILE ============

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Update display name
      await authProvider.updateProfile(_nameController.text);

      // If there's a selected image that wasn't uploaded yet, upload it
      if (_selectedImage != null) {
        await _uploadProfileImage();
      }

      if (mounted) {
        Navigator.pop(context, true);
        Helpers.showSnackBar(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update profile: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}