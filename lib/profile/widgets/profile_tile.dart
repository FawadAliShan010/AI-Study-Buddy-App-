import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white70,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          color: Colors.white54,
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3),
          )
              : null),
      contentPadding: EdgeInsets.zero,
    );
  }
}