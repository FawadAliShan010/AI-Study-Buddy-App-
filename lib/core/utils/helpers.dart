import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} at ${formatTime(date)}';
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String formatStudyTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes min';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeEachWord(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String toTitleCase(String text) {
    final words = text.split(' ');
    return words.map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      if (word.contains('.')) return word;
      return capitalize(word);
    }).join(' ');
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(url);
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      List.generate(length, (index) => chars.codeUnitAt(
        DateTime.now().millisecondsSinceEpoch % chars.length,
      )),
    );
  }

  static Color getColorForSubject(String subject) {
    final colors = {
      'Math': Colors.blue,
      'Science': Colors.green,
      'History': Colors.orange,
      'English': Colors.purple,
      'Art': Colors.pink,
      'Music': Colors.red,
      'Physics': Colors.cyan,
      'Chemistry': Colors.teal,
      'Biology': Colors.lime,
      'Geography': Colors.brown,
      'Computer Science': Colors.indigo,
      'Economics': Colors.amber,
      'Business': Colors.deepOrange,
      'Psychology': Colors.deepPurple,
      'Philosophy': Colors.grey,
    };
    return colors[subject] ?? Colors.grey;
  }

  static String getEmojiForSubject(String subject) {
    final emojis = {
      'Math': '📐',
      'Science': '🔬',
      'History': '📜',
      'English': '📚',
      'Art': '🎨',
      'Music': '🎵',
      'Physics': '⚛️',
      'Chemistry': '🧪',
      'Biology': '🧬',
      'Geography': '🌍',
      'Computer Science': '💻',
      'Economics': '📊',
      'Business': '💼',
      'Psychology': '🧠',
      'Philosophy': '📖',
    };
    return emojis[subject] ?? '📝';
  }

  static String getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '🟢 Beginner';
      case 'intermediate':
        return '🟡 Intermediate';
      case 'advanced':
        return '🔴 Advanced';
      default:
        return '⚪ $difficulty';
    }
  }

  static String getQuizScoreLabel(double percentage) {
    if (percentage >= 90) return '🌟 Excellent!';
    if (percentage >= 70) return '👏 Good Job!';
    if (percentage >= 50) return '📖 Keep Learning!';
    return '💪 Keep Practicing!';
  }

  static Color getQuizScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  static void showSnackBar(
      BuildContext context,
      String message, {
        bool isError = false,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
      BuildContext context,
      String title,
      String message, {
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ??
        false;
  }

  static String getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'ppt':
      case 'pptx':
        return '📊';
      case 'xls':
      case 'xlsx':
        return '📈';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
        return '🖼️';
      case 'mp3':
      case 'wav':
      case 'aac':
        return '🎵';
      case 'mp4':
      case 'mov':
      case 'avi':
        return '🎬';
      case 'zip':
      case 'rar':
        return '📦';
      default:
        return '📎';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}