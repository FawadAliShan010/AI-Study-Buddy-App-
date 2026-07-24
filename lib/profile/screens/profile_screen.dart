import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/study_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../widgets/profile_tile.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInDown(
              child: _buildProfileHeader(user),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildStatsSection(studyProvider),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingsSection(),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildAccountSection(authProvider),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppGradients.secondaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.neon,
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'Student',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? '',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user?.emailVerified ?? false ? 'Verified' : 'Not Verified',
              style: GoogleFonts.inter(
                color: user?.emailVerified ?? false ? Colors.green : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(StudyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.timer_rounded,
                value: Helpers.formatStudyTime(provider.studyTime),
                label: 'Study Time',
                color: AppColors.secondary,
              ),
              _buildStatItem(
                icon: Icons.quiz_rounded,
                value: provider.quizzesCompleted.toString(),
                label: 'Quizzes',
                color: AppColors.primary,
              ),
              _buildStatItem(
                icon: Icons.note_rounded,
                value: provider.notesCreated.toString(),
                label: 'Notes',
                color: AppColors.accent,
              ),
              _buildStatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${provider.streak}',
                label: 'Day Streak',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ProfileTile(
            icon: Icons.dark_mode_rounded,
            title: 'Theme',
            subtitle: 'Dark Mode',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement theme toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          ProfileTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Push notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          ProfileTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // TODO: Show language options
            },
          ),
          ProfileTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy',
            subtitle: 'Manage privacy settings',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ProfileTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          ProfileTile(
            icon: Icons.password_rounded,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          ProfileTile(
            icon: Icons.download_rounded,
            title: 'Export Data',
            subtitle: 'Download your data',
            onTap: () {
              // TODO: Implement data export
              Helpers.showSnackBar(context, 'Data export coming soon!');
            },
          ),
          ProfileTile(
            icon: Icons.delete_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              final confirm = await Helpers.showConfirmationDialog(
                context,
                'Delete Account',
                'Are you sure you want to delete your account? This action cannot be undone.',
                confirmText: 'Delete',
              );
              if (confirm) {
                // TODO: Implement account deletion
                Helpers.showSnackBar(context, 'Account deletion coming soon!');
              }
            },
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.accentGradient,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              boxShadow: AppShadows.glow,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseService().signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to sign out: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}