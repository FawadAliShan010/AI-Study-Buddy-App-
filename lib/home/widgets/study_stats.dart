import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';

class StudyStats extends StatelessWidget {
  final int studyTime;
  final int quizzesCompleted;
  final int notesCreated;
  final int streak;
  final Function(String) onStatTap;

  const StudyStats({
    super.key,
    required this.studyTime,
    required this.quizzesCompleted,
    required this.notesCreated,
    required this.streak,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          'Study Time',
          '${studyTime}m',
          Icons.timer_rounded,
          Colors.blue,
              () => onStatTap('Study Time'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Quizzes',
          '$quizzesCompleted',
          Icons.quiz_rounded,
          Colors.green,
              () => onStatTap('Quizzes'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Notes',
          '$notesCreated',
          Icons.note_rounded,
          Colors.orange,
              () => onStatTap('Notes'),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Streak',
          '$streak🔥',
          Icons.local_fire_department_rounded,
          Colors.red,
              () => onStatTap('Streak'),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}