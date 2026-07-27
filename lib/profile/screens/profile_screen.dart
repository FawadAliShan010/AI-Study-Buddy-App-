import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/study_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../core/Widgets/data_export_screen.dart';
import '../../core/Widgets/language_setting_screen.dart';
import '../../core/Widgets/privacy_setting_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../widgets/profile_tile.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
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
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : () => _refreshData(authProvider, studyProvider),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FadeInDown(
                child: _buildProfileHeader(user, authProvider),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildStatsSection(studyProvider),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildSettingsSection(themeProvider),
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
      ),
    );
  }

  Widget _buildProfileHeader(User? user, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.secondaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.neon,
                ),
                child: user?.photoURL != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    user!.photoURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _editProfile(context, authProvider),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.displayName ?? 'Student',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.emailVerified ?? false
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user?.emailVerified ?? false
                          ? Icons.verified_rounded
                          : Icons.warning_rounded,
                      color: user?.emailVerified ?? false ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.emailVerified ?? false ? 'Verified' : 'Not Verified',
                      style: GoogleFonts.inter(
                        color: user?.emailVerified ?? false ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!(user?.emailVerified ?? false)) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _sendVerificationEmail(authProvider),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showDetailedStats(context, provider),
                child: const Text('See All'),
              ),
            ],
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
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: provider.studyTime > 0 ? provider.studyTime / 3600 / 8 : 0,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily Goal: ${Helpers.formatStudyTime(provider.studyTime)} / 8h 0m',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
            ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
      ),
    );
  }

  Widget _buildSettingsSection(ThemeProvider themeProvider) {
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
            subtitle: 'Switch between light and dark mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeThumbColor: AppColors.primary,
            ),
          ),
          ProfileTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Push notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) => _toggleNotifications(context, value),
              activeThumbColor: AppColors.primary,
            ),
          ),
          ProfileTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Select your preferred language',
            onTap: () => _navigateToScreen(context, const LanguageSettingsScreen()),
          ),
          ProfileTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy',
            subtitle: 'Manage privacy settings',
            onTap: () => _navigateToScreen(context, const PrivacySettingsScreen()),
          ),
          ProfileTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          ProfileTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            onTap: () => _showSupportOptions(context),
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
            subtitle: 'Update your personal information',
            onTap: () => _editProfile(context, authProvider),
          ),
          ProfileTile(
            icon: Icons.password_rounded,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _navigateToScreen(context, const ChangePasswordScreen()),
          ),
          ProfileTile(
            icon: Icons.download_rounded,
            title: 'Export Data',
            subtitle: 'Download your study data',
            onTap: () => _navigateToScreen(context, const DataExportScreen()),
          ),
          ProfileTile(
            icon: Icons.share_rounded,
            title: 'Share App',
            subtitle: 'Share with your friends',
            onTap: _shareApp,
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
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                confirmText: 'Delete',
              );
              if (confirm) {
                await _deleteAccount(context, authProvider);
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
              onPressed: _isSigningOut ? null : _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
              ),
              child: _isSigningOut
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

  // ============ ACTION METHODS ============

  Future<void> _refreshData(AuthProvider authProvider, StudyProvider studyProvider) async {
    setState(() => _isRefreshing = true);
    try {
      await authProvider.refreshUser();
      final userId = authProvider.userId;
      if (userId!.isNotEmpty) {
        await studyProvider.loadStudyData(userId);
      }
      if (mounted) {
        Helpers.showSnackBar(context, 'Data refreshed successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to refresh data: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _editProfile(BuildContext context, AuthProvider authProvider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: authProvider.user),
      ),
    );
    if (result == true && mounted) {
      await authProvider.refreshUser();
      setState(() {});
    }
  }

  Future<void> _sendVerificationEmail(AuthProvider authProvider) async {
    try {
      await authProvider.sendEmailVerification();
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Verification email sent! Please check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to send verification email: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _toggleNotifications(BuildContext context, bool value) async {
    Helpers.showSnackBar(
      context,
      value ? 'Notifications enabled' : 'Notifications disabled',
    );
  }

  Future<void> _signOut() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      'Sign Out',
      'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (!confirm) return;

    setState(() => _isSigningOut = true);
    try {
      await FirebaseService().signOut();
      if (mounted) {
        // Use pushAndRemoveUntil to go to LoginScreen and clear all routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to sign out: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, AuthProvider authProvider) async {
    setState(() => _isSigningOut = true);
    try {
      await authProvider.deleteAccount();
      if (mounted) {
        // Use pushAndRemoveUntil to go to LoginScreen and clear all routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
        Helpers.showSnackBar(context, 'Account deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to delete account: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  void _showDetailedStats(BuildContext context, StudyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detailed Statistics',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailItem('Total Study Time', Helpers.formatStudyTime(provider.studyTime)),
            _buildDetailItem('Total Quizzes', provider.quizzesCompleted.toString()),
            _buildDetailItem('Total Notes', provider.notesCreated.toString()),
            _buildDetailItem('Current Streak', '${provider.streak} days'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'About Study App',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'A modern study companion app designed to help you track your study progress, take quizzes, and manage your learning journey.',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Developed by: Fawad Ali Shan',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            Text(
              '© 2026 All Rights Reserved',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Support',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email_rounded, color: AppColors.primary),
              title: Text(
                'Email Support',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'support@yourapp.com',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
              onTap: () => _launchEmail('support@yourapp.com'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_rounded, color: AppColors.primary),
              title: Text(
                'Live Chat',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Available 24/7',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
              onTap: () => Helpers.showSnackBar(context, 'Live chat coming soon!'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_rounded, color: AppColors.primary),
              title: Text(
                'Send Feedback',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Help us improve',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
              onTap: () => Helpers.showSnackBar(context, 'Feedback feature coming soon!'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        'Check out this amazing Study App! 🎓\n\n'
            'Track your study progress, take quizzes, and more!\n\n'
            'Download now: https://yourapp.com/download',
        subject: 'Study App - Your Learning Companion',
      );
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to share: $e', isError: true);
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request - Study App',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          Helpers.showSnackBar(context, 'Could not launch email app', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to open email: $e', isError: true);
      }
    }
  }
}