import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: ListView(
        children: [
          _buildLanguageTile('English', 'en', Icons.language),
          _buildLanguageTile('Spanish', 'es', Icons.language),
          _buildLanguageTile('French', 'fr', Icons.language),
          _buildLanguageTile('German', 'de', Icons.language),
          _buildLanguageTile('Japanese', 'ja', Icons.language),
          _buildLanguageTile('Chinese', 'zh', Icons.language),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(String name, String code, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: _selectedLanguage == code
          ? const Icon(Icons.check_circle_rounded, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        // Implement language change logic
      },
    );
  }
}