import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/chat_provider.dart';

class SuggestionChips extends StatelessWidget {
  const SuggestionChips({super.key});

  final List<String> _suggestions = const [
    'Explain quantum physics',
    'Help with calculus',
    'Study tips for exams',
    'Practice problems',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _suggestions.map((suggestion) {
        return FadeInUp(
          delay: Duration(milliseconds: 200 + _suggestions.indexOf(suggestion) * 100),
          child: ActionChip(
            label: Text(
              suggestion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            onPressed: () {
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.sendMessage(suggestion);
            },
            backgroundColor: Colors.white.withOpacity(0.1),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }).toList(),
    );
  }
}